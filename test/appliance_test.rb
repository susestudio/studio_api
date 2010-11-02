require 'rubygems'
require 'active_support'
require 'active_resource/http_mock'
require 'mocha'
require 'test/unit'
$:.unshift File.join( File.dirname(__FILE__),'..','lib')
require 'studio_api/appliance'
require 'studio_api/connection'

class ApplianceTest < Test::Unit::TestCase
APPLIANCE_ID = 266657
REPO_ID = 6345
  def respond_load name
    IO.read(File.join(File.dirname(__FILE__),"responses",name))
  end

  def setup
    @connection = StudioApi::Connection.new("test","test","http://localhost")
    StudioApi::Appliance.set_connection @connection
    appliances_out = respond_load "appliances.xml"
    appliance_out = respond_load "appliance.xml"
    status_out = respond_load "status.xml"
    repositories_out = respond_load "repositories.xml"
    software_out = respond_load "software.xml"
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/appliances", {"Authorization"=>"Basic dGVzdDp0ZXN0"},appliances_out,200
      mock.get "/appliances/#{APPLIANCE_ID}", {"Authorization"=>"Basic dGVzdDp0ZXN0"},appliance_out,200
      mock.get "/appliances/#{APPLIANCE_ID}/status", {"Authorization"=>"Basic dGVzdDp0ZXN0"},status_out,200
      mock.post "/appliances?appliance_id=#{APPLIANCE_ID}", {"Authorization"=>"Basic dGVzdDp0ZXN0"},appliance_out,200 #correct output should be clone of appliance, but it is not important in test
      mock.delete "/appliances/#{APPLIANCE_ID}", {"Authorization"=>"Basic dGVzdDp0ZXN0"},appliance_out,200 
      mock.get "/appliances/#{APPLIANCE_ID}/repositories", {"Authorization"=>"Basic dGVzdDp0ZXN0"},repositories_out,200
      mock.post "/appliances/#{APPLIANCE_ID}/cmd/remove_repository?repo_id=#{REPO_ID}",{"Authorization"=>"Basic dGVzdDp0ZXN0"},repositories_out,200
      mock.post "/appliances/#{APPLIANCE_ID}/cmd/add_repository?repo_id=#{REPO_ID}",{"Authorization"=>"Basic dGVzdDp0ZXN0"},repositories_out,200
      mock.post "/appliances/#{APPLIANCE_ID}/cmd/add_user_repository",{"Authorization"=>"Basic dGVzdDp0ZXN0"},repositories_out,200
      mock.get "/appliances/#{APPLIANCE_ID}/software",{"Authorization"=>"Basic dGVzdDp0ZXN0"},software_out,200
    end
  end

  def test_find_all
    res = StudioApi::Appliance.find :all
    assert_equal 7,res.size
  end

  def test_find_one
    res = StudioApi::Appliance.find APPLIANCE_ID
    assert_equal APPLIANCE_ID.to_s, res.id
  end

  def test_status
    res = StudioApi::Appliance.find APPLIANCE_ID
    assert_equal "ok", res.status.state
  end

  def test_clone
    assert StudioApi::Appliance.new(:id => APPLIANCE_ID).clone
  end

  def test_delete
    assert StudioApi::Appliance.delete APPLIANCE_ID
  end

  def test_repositories
    res = StudioApi::Appliance.new(:id => APPLIANCE_ID).repositories
    assert_equal 5,res.size
  end

  def test_repository_remove
    appliance = StudioApi::Appliance.new(:id => APPLIANCE_ID)
    assert appliance.remove_repository REPO_ID
    repo = appliance.repositories.detect { |r| r.id == REPO_ID.to_s}
    assert repo.delete #another way to delete repository
  end

  def test_repository_add
    assert StudioApi::Appliance.new(:id => APPLIANCE_ID).add_repository REPO_ID
  end

  def test_user_repository_add
    assert StudioApi::Appliance.new(:id => APPLIANCE_ID).add_user_repository
  end

  def test_selected_software
    res = StudioApi::Appliance.new(:id => APPLIANCE_ID).selected_software
    debugger
    assert_equal 5,res.size
  end
end
