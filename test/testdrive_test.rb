require 'test_helper'

class TestdriveTest < Test::Unit::TestCase
  def setup
    @build_id = 12345

    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = false
    @connection = StudioApi::Connection.new(@@username, @@password,"http://localhost/api/")
    StudioApi::Testdrive.studio_connection = @connection
  end

  def test_find
    register_fake_response_from_file :get, "/api/testdrives",
                                     'testdrives.xml'
    res = StudioApi::Testdrive.find :all
    assert_equal 1, res.size
  end

  def test_new
    register_fake_response_from_file :post, "/api/testdrives?build_id=#{@build_id}",
                                     'testdrive.xml'
    assert StudioApi::Testdrive.new(:build_id => @build_id).save
  end
end
