require 'test_helper'

class RunningBuildTest < Test::Unit::TestCase

  def setup
    @build_id = 529783
    @appliance_id = 269186

    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = false
    @connection = StudioApi::Connection.new(@@username, @@password,"http://localhost/api/")
    StudioApi::RunningBuild.studio_connection = @connection
  end

  def teardown
    FakeWeb.allow_net_connect = false
  end

  def test_find
    register_fake_response_from_file :get, "/api/running_builds?appliance_id=#{@appliance_id}",
                                     'running_builds.xml'
    res = StudioApi::RunningBuild.find :all, :params => {:appliance_id => @appliance_id}
    assert_equal 3, res.size

    register_fake_response_from_file :get, "/api/running_builds/#{@build_id}",
                                     'running_build.xml'
    res = StudioApi::RunningBuild.find @build_id
    assert_equal @build_id, res.id.to_i
  end

  def test_cancel
    register_fake_response_from_file :get, "/api/running_builds/#{@build_id}",
                                     'running_build.xml'
    running_build = StudioApi::RunningBuild.find @build_id

    register_fake_response_from_file :delete, "/api/running_builds/#{@build_id}",
                                     'running_build.xml'
    assert running_build.destroy
    assert StudioApi::RunningBuild.delete @build_id
    assert running_build.cancel #test alias
  end

  def test_run_new
    register_fake_response_from_file :post, "/api/running_builds?appliance_id=#{@appliance_id}&force=true",
                                     'running_build.xml'
    assert StudioApi::RunningBuild.new(:appliance_id => @appliance_id, :force => true).save
  end

  def test_find_image_already_exists_error
    register_fake_response_from_file :post, "/api/running_builds?appliance_id=#{@appliance_id}",
                                     'running_build_image_already_exists.xml',
                                     ["400", "Bad Request"]

    assert_raises StudioApi::ImageAlreadyExists do
      StudioApi::RunningBuild.new(:appliance_id => @appliance_id).save
    end
  end
end
