require 'test/unit'
require 'mocha'
require 'webmock/test_unit'
$: << File.dirname(__FILE__) + '/../lib'
puts "about to load"
require 'heroku/command/ssl'

class TestSsl < Test::Unit::TestCase

  def stub_auth
    # Heroku::Command::Auth.any_instance.stubs(:ask_for_credentials).returns(["user", "secret"])
    # Heroku::Command::Ssl.any_instance.stubs(:extract_app).returns("myapp")
    # Heroku::Client.any_instance.stubs(:list).returns([])
  end

  def setup
    stub_auth
    stub_request(:any, /api\.heroku\.com/).to_return(:body => OkJson.encode({}))
  end

  def test_adds_pem_and_key_to_app
    pemfile = "#{File.dirname(__FILE__)}/fixtures/cert.pem"
    keyfile = "#{File.dirname(__FILE__)}/fixtures/cert.key"
    Heroku::Command.run("ssl:add", [pemfile, keyfile, "--app", "myapp"])
    assert_requested(:post, %r{api\.heroku\.com/addons/install$}) do |request|
      request.body =~ /Content-Disposition: form-data;/ &&
      request.body =~ /name="id"\r\n\r\nmyapp\r\n/ &&
      request.body =~ /name="addon"\r\n\r\nssl:hostname_new\r\n/ &&
      request.body =~ %r{name="config\[pem_file\]"; filename="cert\.pem"\r\nContent-Type: text/plain\r\n\r\nmy PEM file contents} &&
      request.body =~ %r{name="config\[key_file\]"; filename="cert\.key"\r\nContent-Type: text/plain\r\n\r\nmy KEY file contents}
    end

  end

end
