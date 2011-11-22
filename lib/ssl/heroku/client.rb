class Heroku::Client
  alias_method :add_ssl_old,    :add_ssl
  alias_method :remove_ssl_old, :remove_ssl
  alias_method :clear_ssl_old,  :clear_ssl

  def ssl_list(app)
    json_decode(get("v3/apps/#{app}/ssl", :accept => :json).to_s)
  end

  def ssl_add(app, pem, key)
    json_decode(post("v3/apps/#{app}/ssl", :accept => :json, :pem => pem, :key => key).to_s)
  end

  def ssl_remove(app, cname)
    json_decode(delete("v3/apps/#{app}/ssl/#{escape(cname)}", :accept => :json).to_s)
  end
end
