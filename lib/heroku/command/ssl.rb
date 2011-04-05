class Heroku::Client
  def add_ssl(app_name, pemfile, keyfile)
    response = JSON.parse post("/addons/install",
      { :id =>app_name, :addon => "ssl:hostname_new",
        :config => { :pem_file => pemfile, :key_file => keyfile }},
      :accept => 'json')
    display_message_or_errors(response, "certificate added")
  end

  def display_message_or_errors(response, success_message)
    response["errors"] && !response["errors"].empty? ? response["errors"].join("\n") : success_message
  end
end

module Heroku::Command
  class Ssl < BaseWithApp
    Help.group("SSL") do |group|
      group.command "ssl:add",         "adds SSL certificates to app"
      group.command "ssl:remove",      "removes SSL from app"
    end

    def add
      app = extract_app
      if args.empty? && args.size != 2
        raise CommandFailed, "usage: heroku ssl:add <pemfile.pem> <keyfile.key>"
      end
      pemfile = File.new(args.shift, "r")
      keyfile = File.new(args.shift, "r")
      puts heroku.add_ssl(app, pemfile, keyfile)
      return
    end

  end
end
