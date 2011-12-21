require "heroku/command/base"

# new interface to SSL endpoints
#
class Heroku::Command::Ssl < Heroku::Command::BaseWithApp

  include Heroku::RunWithStatus

  # ssl
  #
  # list SSL endpoints for an app
  #
  def index
    endpoints = heroku.ssl_list(app)

    if endpoints.empty?
      display "No SSL endpoints setup."
      display "Use 'heroku ssl:add <pemfile> <keyfile>' to create a SSL endpoint."
    else
      endpoints.map! do |endpoint|
        endpoint["domain"] = endpoint["ssl_cert"]["cert_domains"].join(", ")
        endpoint["expires"] = Time.parse(endpoint["ssl_cert"]["expires_at"]).strftime("%Y-%m-%d %H:%M:%S")
        endpoint
      end

      display_table endpoints, %w( cname domain expires ), ["Endpoint" "Domain" "Cert Expires"]
    end
  end

  # ssl:add PEM KEY
  #
  # adds SSL endpoint to an app
  #
  def add
    if args.size < 2
      fail("Usage: heroku ssl:add PEM KEY")
    end

    pem = File.read(args[0]) rescue error("Unable to read PEM")
    key = File.read(args[1]) rescue error("Unable to read KEY")
    app = self.respond_to?(:extract_app) ? self.extract_app : self.app

    info = nil
    run_with_status("-----> Adding SSL endpoint to #{app}") do
      info = heroku.ssl_add(app, pem, key)
    end

    display "       #{app} now served by #{info['cname']}"
  end

  # ssl:remove CNAME
  #
  # removes SSL endpoint from the app
  #
  def remove
    cname = args.first || error("Usage: heroku ssl:remove CNAME")
    run_with_status("-----> Removing SSL endpoint #{cname} from #{app}") do
      heroku.ssl_remove(app, cname)
    end
  end

end
