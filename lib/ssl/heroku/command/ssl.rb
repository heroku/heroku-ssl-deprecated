require "heroku/command"
require "heroku/command/base"

Heroku::Command.commands.delete("ssl:add")
Heroku::Command.commands.delete("ssl:remove")
Heroku::Command.commands.delete("ssl:clear")

class Heroku::Command::Ssl < Heroku::Command::BaseWithApp

  # ssl:add PEM KEY
  #
  # add an ssl certificate to an app
  #
  def add
    raise CommandFailed, "Missing pem file." unless pem_file = args.shift
    raise CommandFailed, "Missing key file." unless key_file = args.shift
    raise CommandFailed, "Could not find pem in #{pem_file}"  unless File.exists?(pem_file)
    raise CommandFailed, "Could not find key in #{key_file}"  unless File.exists?(key_file)
    pem  = File.new(pem_file, "r")
    key  = File.new(key_file, "r")
    display heroku.add_ssl(app, pem, key)
  end

end

# deprecated ssl management
#
class Heroku::Command::SslOld < Heroku::Command::BaseWithApp

  # sslold:add PEM KEY
  #
  # add an ssl certificate to an app
  #
  def add
    raise CommandFailed, "Missing pem file." unless pem_file = args.shift
    raise CommandFailed, "Missing key file." unless key_file = args.shift
    raise CommandFailed, "Could not find pem in #{pem_file}"  unless File.exists?(pem_file)
    raise CommandFailed, "Could not find key in #{key_file}"  unless File.exists?(key_file)

    pem  = File.read(pem_file)
    key  = File.read(key_file)
    info = heroku.add_ssl_old(app, pem, key)
    display "Added certificate to #{info['domain']}, expiring in #{info['expires_at']}"
  end

  # sslold:remove DOMAIN
  #
  # remove an ssl certificate from an app
  #
  def remove
    raise CommandFailed, "Missing domain. Usage:\nheroku ssl:remove <domain>" unless domain = args.shift
    heroku.remove_ssl_old(app, domain)
    display "Removed certificate from #{domain}"
  end

  # sslold:clear
  #
  # remove all ssl certificates from an app
  #
  def clear
    heroku.clear_ssl_old(app)
    display "Cleared certificates for #{app}"
  end

end
