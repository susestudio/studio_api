require 'rubygems'
require 'active_support'
require 'active_resource/http_mock'
require 'mocha'
require 'test/unit'
$:.unshift File.join( File.dirname(__FILE__),'..','lib')
require 'studio_api/resource'
require 'studio_api/connection'

class MyTest < StudioApi::Resource
end

class ResourceTest < Test::Unit::TestCase
  def setup
    @connection = StudioApi::Connection.new("test","test","http://localhost")
    MyTest.set_connection @connection
  end

  def test_site
    assert_equal "/my_tests", MyTest.collection_path
    assert_equal "http://localhost/", MyTest.site.to_s
  end
end
