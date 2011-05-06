require File.expand_path('../../lib/studio_api',__FILE__)

require 'fakeweb'
require 'mocha'
require 'test/unit'

class Test::Unit::TestCase
  @@username = "foo"
  @@password = "api_password"
  private

  def register_fake_response request_type, request, response,
                             status = ["200", "OK"]
    url = "http://#{@@username}:#{@@password}@localhost#{request}"
    FakeWeb.register_uri(request_type, url, :body => response, :status => status)
  end

  def register_fake_response_from_file request_type, request, response_file_name,
                                       status = ["200", "OK"]
    response = IO.read(File.join(File.dirname(__FILE__),"responses",
                                 response_file_name))
    register_fake_response request_type, request, response, status
  end
end

