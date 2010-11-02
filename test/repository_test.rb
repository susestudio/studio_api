require 'rubygems'
require 'active_support'
require 'active_resource/http_mock'
require 'test/unit'
require 'mocha'
$:.unshift File.join( File.dirname(__FILE__),'..','lib')
require 'studio_api/repository'
require 'studio_api/appliance'
require 'studio_api/connection'

class ApplianceTest < Test::Unit::TestCase
REPOSITORY_ID = 6343
  def respond_load name
    IO.read(File.join(File.dirname(__FILE__),"responses",name))
  end
  def setup
    @connection = StudioApi::Connection.new("test","test","http://localhost")
    StudioApi::Repository.set_connection @connection
    repositories_out = respond_load "repositories.xml"
    repository_out = respond_load "repository.xml"
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/repositories?base_system=sle11sp1", {"Authorization"=>"Basic dGVzdDp0ZXN0"},repositories_out,200
      mock.post "/repositories?name=test&url=http%3A%2F%2Ftest", {"Authorization"=>"Basic dGVzdDp0ZXN0"},repository_out,200
      mock.get "/repositories/#{REPOSITORY_ID}", {"Authorization"=>"Basic dGVzdDp0ZXN0"},repository_out,200
    end
  end

  def test_find
    res = StudioApi::Repository.find :all, :params => {:base_system => "sle11sp1"}
    assert_equal 5,res.size
    res = StudioApi::Repository.find REPOSITORY_ID
    assert_equal REPOSITORY_ID, res.id.to_i
  end

  def test_import
    res = StudioApi::Repository.import "http://test","test"
    assert res
    assert_equal REPOSITORY_ID, res.id.to_i
  end
end

