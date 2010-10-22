require 'rubygems'
require 'active_support'
require 'active_resource/http_mock'
require 'test/unit'
require 'mocha'
$:.unshift File.join( File.dirname(__FILE__),'..','lib')
require 'studio_api/generic_request'
require 'studio_api/connection'

class GenericRequestTest < Test::Unit::TestCase
  def setup
    @connection = StudioApi::Connection.new("test","test","http://localhost")
  end

  def test_get
    test_response = "Test response"
    StudioApi::GenericRequest.any_instance.stubs(:do_request).returns test_response
    assert_equal test_response, StudioApi::GenericRequest.new(@connection).get("test")
  end

  def test_post
    test_response = "Test response"
    StudioApi::GenericRequest.any_instance.stubs(:do_request).returns test_response
    assert_equal test_response, StudioApi::GenericRequest.new(@connection).post("test",:file => "/dev/zero")
  end
end
