require "rubygems"
$:.unshift File.join( File.dirname(__FILE__),'..','lib')
require 'studio_api/connection'
require 'studio_api/generic_request'

require 'mocha'
require 'test/unit'

class ResourceTest < Test::Unit::TestCase
  def setup
    @connection = StudioApi::Connection.new("test","test","http://localhost/api/user")
  end

FAKE_API_VERSION_RESPONSE = "<version>1.0</version>"
  def test_api_version
    StudioApi::GenericRequest.any_instance.stubs(:get).with("/api_version").returns(FAKE_API_VERSION_RESPONSE).once
    assert_equal "1.0",@connection.api_version
    @connection.api_version #test caching, if it again call, then mocha raise exception
  end

end
