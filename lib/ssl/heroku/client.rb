class Heroku::Client
  alias_method :add_ssl_old,    :add_ssl
  alias_method :remove_ssl_old, :remove_ssl
  alias_method :clear_ssl_old,  :clear_ssl

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


