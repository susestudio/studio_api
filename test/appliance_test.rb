require 'rubygems'
require 'active_support'
require 'active_resource/http_mock'
require 'test/unit'
require 'mocha'
$:.unshift File.join( File.dirname(__FILE__),'..','lib')
require 'studio_api/appliance'
require 'studio_api/connection'

class ApplianceTest < Test::Unit::TestCase

  def respond_load name
    IO.read(File.join(File.dirname(__FILE__),"responses",name))
  end

  def setup
    @connection = StudioApi::Connection.new("test","test","http://localhost")
    StudioApi::Appliance.set_connection @connection
    appliances_out = respond_load "appliances.xml"
    appliance_out = respond_load "appliance.xml"
    status_out = respond_load "status.xml"
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/appliances", {"Authorization"=>"Basic dGVzdDp0ZXN0"},appliances_out,200
      mock.get "/appliances/266657", {"Authorization"=>"Basic dGVzdDp0ZXN0"},appliance_out,200
      mock.get "/appliances/266657/status", {"Authorization"=>"Basic dGVzdDp0ZXN0"},status_out,200
      mock.post "/appliances?appliance_id=266657", {"Authorization"=>"Basic dGVzdDp0ZXN0"},appliance_out,200 #correct output should be clone of appliance, but it is not important in test
    end
  end

  def test_find_all
    res = StudioApi::Appliance.find :all
    assert_equal 7,res.size
  end

  def test_find_one
    res = StudioApi::Appliance.find 266657
    assert_equal "266657", res.id
  end

  def test_status
    res = StudioApi::Appliance.find 266657
    assert_equal "ok", res.status.state
  end

  def test_clone
    assert StudioApi::Appliance.clone 266657
  end
end
