require "heroku/command/base"
class Heroku::Client
  def add_ssl(app_name, pemfile, keyfile)
    response = post("/addons/install",
                    { :id => app_name, :addon => "ssl:hostname_new",
                      :config => { :pem_file => pemfile, :key_file => keyfile }},
                      :accept => 'json')
    json = OkJson.decode(response)
    display_message_or_errors(json, "certificate added")
  end

  def display_message_or_errors(response, success_message)
    response["errors"] && !response["errors"].empty? ? response["errors"].join("\n") : success_message
  end
end

module Heroku::Command

  # manage ssl certificates for an app
  #
  class Ssl < BaseWithApp

    # ssl:add PEM KEY
    #
    # add an ssl certificate to an app
    #
    def new
      raise CommandFailed, "Missing pem file." unless pem_file = args.shift
      raise CommandFailed, "Missing key file." unless key_file = args.shift
      raise CommandFailed, "Could not find pem in #{pem_file}"  unless File.exists?(pem_file)
      raise CommandFailed, "Could not find key in #{key_file}"  unless File.exists?(key_file)
      pem  = File.new(pem_file, "r")
      key  = File.new(key_file, "r")
      display heroku.add_ssl(app, pem, key)
    end
  end
end

