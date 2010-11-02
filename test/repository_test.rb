require 'rubygems'
require 'active_support'
require 'active_resource/http_mock'
require 'test/unit'
require 'mocha'
$:.unshift File.join( File.dirname(__FILE__),'..','lib')
require 'studio_api/repository'
require 'studio_api/connection'

class ApplianceTest < Test::Unit::TestCase

  def respond_load name
    IO.read(File.join(File.dirname(__FILE__),"responses",name))
  end
APPLIANCE_ID = 266657
  def setup
    @connection = StudioApi::Connection.new("test","test","http://localhost")
    StudioApi::Repository.set_connection @connection
    repositories_out = respond_load "repositories.xml"
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/appliances/#{APPLIANCE_ID}/repositories", {"Authorization"=>"Basic dGVzdDp0ZXN0"},repositories_out,200
    end
  end

  def test_find
    res = StudioApi::Repository.find :all, :params => {:appliance_id => APPLIANCE_ID}
    assert_equal 5,res.size
  end
end

