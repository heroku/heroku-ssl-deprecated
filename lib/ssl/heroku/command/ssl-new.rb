require "heroku/command/base"

# new interface to SSL endpoints
#
class Heroku::Command::Ssl < Heroku::Command::BaseWithApp

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
      endpoints.each do |endpoint|
        expiration = Time.parse(endpoint['ssl_cert']['expires_at'])
        display "* #{endpoint['cname']}"
        display "  for: #{endpoint['ssl_cert']['cert_domains'].join(', ')}"
        display "  expires at: #{expiration.strftime("%Y-%m-%d")}"
      end
    end
  end

  # ssl:add PEM KEY
  #
  # adds SSL endpoint to an app
  #
  def add
    pem = File.read(args[0]) rescue error("Unable to read PEM")
    key = File.read(args[1]) rescue error("Unable to read KEY")
    app = extract_app
    info = nil

    display "Adding SSL Endpoint to #{app}... ", false
    info = heroku.ssl_add(app, pem, key)
    expiration = Time.parse(info['ssl_cert']['expires_at'])
    display "Done"
    display "#{app} now served by #{info["cname"]}"
    display "  Certificate domains: #{info['ssl_cert']['cert_domains'].join(', ')}"
    display "  Expires at: #{expiration.strftime("%Y-%m-%d")}"
  end

  # ssl:remove CNAME
  #
  # removes SSL endpoint from the app
  #
  def remove
    cname = args.first || error("Must specify a CNAME")
    display "Removing SSL Endpoint #{cname}...", false
    heroku.ssl_remove(app, cname)
    display "Done"
  end

end
