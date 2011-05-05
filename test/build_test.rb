require 'test_helper'

class BuildTest < Test::Unit::TestCase

  def setup
    @build_id = 509559
    @appliance_id = 269186

    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = false
    @connection = StudioApi::Connection.new(@@username, @@password,"http://localhost/api/")
    StudioApi::Build.studio_connection = @connection
  end
  
  def teardown
    FakeWeb.allow_net_connect = false
  end

  def test_find
    register_fake_response_from_file :get, "/api/builds?appliance_id=#{@appliance_id}",
                                     'builds.xml'
    res = StudioApi::Build.find :all, :params => {:appliance_id => @appliance_id}
    assert_equal 1, res.size

    register_fake_response_from_file :get, "/api/builds/#{@build_id}",
                                     'build.xml'
    res = StudioApi::Build.find @build_id
    assert_equal "true", res.expired
  end

  def test_delete
    register_fake_response_from_file :get, "/api/builds/#{@build_id}",
                                     'build.xml'
    register_fake_response_from_file :delete, "/api/builds/#{@build_id}",
                                     'build.xml'

    build = StudioApi::Build.find @build_id
    assert build.destroy
    assert StudioApi::Build.delete @build_id
  end

end
