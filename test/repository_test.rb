require 'test_helper'

class RepositoryTest < Test::Unit::TestCase
  def setup
    @repository_id = 6343

    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = false
    @connection = StudioApi::Connection.new(@@username, @@password,"http://localhost/api/")
    StudioApi::Repository.studio_connection = @connection
  end

  def teardown
    FakeWeb.allow_net_connect = false
  end

  def test_find
    register_fake_response_from_file :get, "/api/repositories?base_system=sle11sp1",
                                     'repositories.xml'
    
    res = StudioApi::Repository.find :all, :params => {:base_system => "sle11sp1"}
    assert_equal 5,res.size

    register_fake_response_from_file :get, "/api/repositories/#{@repository_id}",
                                     'repository.xml'
    res = StudioApi::Repository.find @repository_id
    assert_equal @repository_id, res.id.to_i
  end

  def test_import
   register_fake_response_from_file :post, "/api/repositories?name=test&url=http%3A%2F%2Ftest",
                                    'repository.xml'
   res = StudioApi::Repository.import "http://test","test"
   assert res
   assert_equal @repository_id, res.id.to_i
  end
end

