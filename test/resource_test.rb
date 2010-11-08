require 'rubygems'
require 'active_support'
$:.unshift File.join( File.dirname(__FILE__),'..','lib')
require 'studio_api/resource'
require 'studio_api/connection'

require 'active_resource/http_mock'
require 'mocha'
require 'test/unit'

class MyTest < StudioApi::Resource
end

class MyTest2 < StudioApi::Resource
  self.prefix = "/appliance/:test/"
end

class ResourceTest < Test::Unit::TestCase
  def setup
    @connection = StudioApi::Connection.new("test","test","http://localhost/api/user")
    MyTest.studio_connection = @connection
    MyTest2.studio_connection = @connection
  end

  def test_site
    assert_equal "/api/user/my_tests", MyTest.collection_path
    assert_equal "http://localhost/api/user/", MyTest.site.to_s
    assert_equal "/api/user/appliance/lest/my_test2s", MyTest2.collection_path(:test => "lest")
  end
end
