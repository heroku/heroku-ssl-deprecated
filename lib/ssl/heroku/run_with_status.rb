module Heroku::RunWithStatus

  def self.included_into
    @@included_into ||= []
  end

  def self.extended_into
    @@extended_into ||= []
  end

  def self.included(base)
    included_into << base
  end

  def self.extended(base)
    extended_into << base
  end

  def self.enable
    included_into.each do |base|
      base.send(:alias_method, :error_without_failure, :error)
      base.send(:alias_method, :error, :error_with_failure)
    end
    extended_into.each do |base|
      class << base
        alias_method :error_without_failure, :error
        alias_method :error, :error_with_failure
      end
    end
    @warning_message = nil
    @old_on_warning = Heroku::Auth.client.on_warning
    Heroku::Auth.client.on_warning { |msg| Heroku::RunWithStatus.record_warning(msg) }
  end

  def self.disable
    included_into.each do |base|
      base.send(:alias_method, :error, :error_without_failure)
    end
    extended_into.each do |base|
      class << base
        alias_method :error, :error_without_failure
      end
    end
    Heroku::Auth.client.on_warning &@old_on_warning
  end

  def self.record_warning(message)
    @warning_message = message
  end

  def self.warning_message
    @warning_message
  end

  def run_with_status(status)
    display "#{status}... ", false
    Heroku::RunWithStatus.enable
    @release = nil
    yield
    Heroku::RunWithStatus.disable
    display @release ? "done, #{@release}" : "done"
    if warning = Heroku::RunWithStatus.warning_message
      display
      display warning
    end
  end

  def error_with_failure(message="")
    display "failed"
    STDERR.puts rewrite_error_format(message)
    exit 1
  end

  def rewrite_error_format(message)
    message.gsub(/ \!   /, ' !     ')
  end

end

