require 'test_helper'

class ConnectionTest < Test::Unit::TestCase
  def setup
    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = false
    @connection = StudioApi::Connection.new(@@username, @@password,"http://localhost/api/")
  end

  def teardown
    FakeWeb.allow_net_connect = false
  end

  def test_api_version
    register_fake_response_from_file :get, "/api/api_version",
                                     'api_version.xml'
    assert_equal "1.0",@connection.api_version
    @connection.api_version #test caching, if it again call, then mocha raise exception
  end

  def test_default_timeout
    assert_equal 45, @connection.timeout
  end

end
