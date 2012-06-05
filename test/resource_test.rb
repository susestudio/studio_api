require 'test_helper'

class MyTest < ActiveResource::Base
  extend StudioApi::StudioResource
end

class MyTest2 < ActiveResource::Base
  extend StudioApi::StudioResource
  self.prefix = "/appliance/:test/"
end

class C < ActiveResource::Base
  extend StudioApi::StudioResource
  self.collection_name = "Cecka"
end

class ResourceTest < Test::Unit::TestCase
  def setup
    @connection = StudioApi::Connection.new("test","test","http://localhost/api/user")
    MyTest.studio_connection = @connection
    MyTest2.studio_connection = @connection
  end

  def test_site
    assert_equal "/api/user/my_tests", MyTest.collection_path
    assert_equal "http://localhost/api/user", MyTest.site.to_s
    assert_equal "/api/user/appliance/lest/my_test2s", MyTest2.collection_path(:test => "lest")
  end

  def test_concurrent_connection
    con1 = StudioApi::Connection.new("test","test","http://localhost/api/user")
    con2 = StudioApi::Connection.new("test2","test2","http://localhost/api/user")
    c1 = C.dup
    c1.studio_connection = con1
    c2 = C.dup
    c2.studio_connection = con2
    assert_equal "test",c1.studio_connection.user
    assert_equal "test2",c2.studio_connection.user
  end

end

class NoConnectionTest < Test::Unit::TestCase
  def test_find
    assert_raise RuntimeError do
      MyTest.find rand 1000
    end

    assert_raise RuntimeError do
      MyTest2.find rand 100
    end
  end

  def test_message
    MyTest.find rand 100
  rescue RuntimeError => e
    assert_match /Connection to Studio is not set/, e.message
  end

end
