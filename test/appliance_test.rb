require 'test_helper'

class ApplianceTest < Test::Unit::TestCase
  
  def setup
    @appliance_id = 266657
    @repo_id = 6345

    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = false
    @connection = StudioApi::Connection.new(@@username, @@password,"http://localhost/api/")
    StudioApi::Util.configure_studio_connection @connection
  end

  def teardown
    FakeWeb.allow_net_connect = false
  end

  def test_find_all
    register_fake_response_from_file :get, '/api/appliances', 'appliances.xml'
    res = StudioApi::Appliance.find :all
    assert_equal 7,res.size
  end

 def test_find_one
   register_fake_response_from_file :get, "/api/appliances/#{@appliance_id}",
                                    'appliance.xml'
   res = StudioApi::Appliance.find @appliance_id
   assert_equal @appliance_id.to_s, res.id
 end

 def test_status
   register_fake_response_from_file :get, "/api/appliances/#{@appliance_id}",
                                    'appliance.xml'
   register_fake_response_from_file :get, "/api/appliances/#{@appliance_id}/status",
                                    'status.xml'
   res = StudioApi::Appliance.find @appliance_id
   assert_equal "ok", res.status.state
 end

 def test_maintenance_status
   register_fake_response_from_file :get, "/api/appliances/#{@appliance_id}/status",
                                    'status-broken.xml'
   res = StudioApi::Appliance.new(:id => @appliance_id)
   assert_equal "error", res.status.state
 end

 def test_clone
   register_fake_response_from_file :post, "/api/appliances?clone_from=#{@appliance_id}",
                                    'appliance.xml'
   assert StudioApi::Appliance.clone(@appliance_id)
 end

 def test_manifest
   register_fake_response_from_file :get, "/api/appliances/#{@appliance_id}/software/manifest/vmx",
                                    'manifest.xml'
   assert StudioApi::Appliance.new(:id => @appliance_id).manifest_file("vmx")
 end

 def test_delete
   register_fake_response_from_file :get, "/api/appliances/#{@appliance_id}",
                                    'appliance.xml'
   register_fake_response_from_file :delete, "/api/appliances/#{@appliance_id}",
                                    'appliance.xml'
   assert StudioApi::Appliance.delete(@appliance_id)
   assert StudioApi::Appliance.find(@appliance_id).destroy #same but different way
 end

 def test_repositories
   register_fake_response_from_file :get, "/api/appliances/#{@appliance_id}/repositories",
                                    'repositories.xml'
   res = StudioApi::Appliance.new(:id => @appliance_id).repositories
   assert_equal 5,res.size
 end

 def test_repository_remove
   register_fake_response_from_file :get, "/api/appliances/#{@appliance_id}/repositories",
                                    'repositories.xml'
   register_fake_response_from_file :post, "/api/appliances/#{@appliance_id}/cmd/remove_repository?repo_id=#{@repo_id}",
                                    'repositories.xml'
   appliance = StudioApi::Appliance.new(:id => @appliance_id)
   assert appliance.remove_repository(@repo_id)
   repo = appliance.repositories.detect { |r| r.id == @repo_id.to_s}
   assert repo.destroy #another way to delete repository
 end

 def test_repository_add
   register_fake_response_from_file :post, "/api/appliances/#{@appliance_id}/cmd/add_repository?repo_id=#{@repo_id}",
                                    'repositories.xml'
   assert StudioApi::Appliance.new(:id => @appliance_id).add_repository(@repo_id)
 end

 def test_user_repository_add
   register_fake_response_from_file :post, "/api/appliances/#{@appliance_id}/cmd/add_user_repository",
                                    'repositories.xml'
   assert StudioApi::Appliance.new(:id => @appliance_id).add_user_repository
 end

 def test_configuration
   register_fake_response_from_file :get, "/api/appliances/#{@appliance_id}/configuration",
                                    'configuration.xml'
   conf= StudioApi::Appliance.new(:id => @appliance_id).configuration
   assert conf.to_xml
   assert conf
 end

 def test_user_repository_add
   register_fake_response_from_file :post, "/api/appliances/#{@appliance_id}/sharing/test1",
                                    'users_2.xml'
   register_fake_response_from_file :get, "/api/appliances/#{@appliance_id}/sharing",
                                    'users_1.xml'
   register_fake_response_from_file :delete, "/api/appliances/#{@appliance_id}/sharing/test1",
                                    'users_1.xml'
   assert_equal 1, StudioApi::Appliance.new(:id => @appliance_id).users.size
   assert_equal 2, StudioApi::Appliance.new(:id => @appliance_id).add_user("test1").size
   assert_equal 1, StudioApi::Appliance.new(:id => @appliance_id).remove_user("test1").size

   register_fake_response_from_file :get, "/api/appliances/#{@appliance_id}/sharing",
                                    'users_0.xml'
   assert_equal 0, StudioApi::Appliance.new(:id => @appliance_id).users.size
 end

 def test_selected_software
   register_fake_response_from_file :get, "/api/appliances/#{@appliance_id}/software",
                                    'software.xml'
   res = StudioApi::Appliance.new(:id => @appliance_id).selected_software
   assert_equal 48,res.size
   assert res.any? {|r| r.is_a? StudioApi::Pattern }, "Pattern is not loaded"
   assert res.any? {|r| r.name = "sysvinit" && r.version == "2.86-200.1" }, "package with specified version not found"
 end

 def test_installed_software
   register_fake_response_from_file :get, "/api/appliances/#{@appliance_id}/software/installed?build_id=1",
                                    'software_installed.xml'
   res = StudioApi::Appliance.new(:id => @appliance_id).installed_software :build_id => 1
   assert_equal 608,res.size
   assert res.any? {|r| r.is_a? StudioApi::Pattern }, "Pattern is not loaded"
   diag = res.find { |p| p.name == "3ddiag"}
   assert_equal "0.742-32.25",diag.version
   assert_equal 6347,diag.repository_id
 end

 def test_search_software
   register_fake_response_from_file :get, "/api/appliances/#{@appliance_id}/software/search?q=qt",
                                    'software_search.xml'

   res = StudioApi::Appliance.new(:id => @appliance_id).search_software "qt"
   assert_equal 54,res.size
   assert res.any? {|r| r.is_a? StudioApi::Pattern }, "Pattern is not loaded"
   apport = res.find { |p| p.name == "apport-qt"}
   assert_equal "0.114-12.7.10",apport.version
   assert_equal 6347,apport.repository_id
 end

 def test_manipulate_with_packages_and_pattern
   register_fake_response_from_file :post, "/api/appliances/#{@appliance_id}/cmd/add_package?name=3ddiag",
                                    'software_fake_response.xml'
   register_fake_response_from_file :post, "/api/appliances/#{@appliance_id}/cmd/remove_package?name=3ddiag",
                                    'software_fake_response.xml'
   register_fake_response_from_file :post, "/api/appliances/#{@appliance_id}/cmd/add_pattern?name=kde4",
                                    'software_fake_response.xml'
   register_fake_response_from_file :post, "/api/appliances/#{@appliance_id}/cmd/remove_pattern?name=kde4",
                                    'software_fake_response.xml'
   register_fake_response_from_file :post, "/api/appliances/#{@appliance_id}/cmd/ban_package?name=3ddiag",
                                    'software_fake_response.xml'
   register_fake_response_from_file :post, "/api/appliances/#{@appliance_id}/cmd/unban_package?name=3ddiag",
                                    'software_fake_response.xml'

   appliance = StudioApi::Appliance.new(:id => @appliance_id)
   assert appliance.add_package("3ddiag")
   assert appliance.remove_package("3ddiag")
   assert appliance.add_pattern("kde4")
   assert appliance.remove_pattern("kde4")
   assert appliance.ban_package("3ddiag")
   assert appliance.unban_package("3ddiag")
 end

 def test_gpg_keys
   register_fake_response_from_file :get, "/api/appliances/#{@appliance_id}/gpg_keys",
                                    'gpg_keys.xml'
   res = StudioApi::Appliance.new(:id => @appliance_id).gpg_keys
   assert_equal 3,res.size
 end

 def test_gpg_key
   gpg_key_id = 1976
   register_fake_response_from_file :get, "/api/appliances/#{@appliance_id}/gpg_keys/#{gpg_key_id}",
                                    'gpg_key.xml'
   res = StudioApi::Appliance.new(:id => @appliance_id).gpg_key(gpg_key_id)
   assert_equal gpg_key_id, res.id.to_i
   assert_equal "rpm", res.target
 end

 def test_delete_gpg_key
   gpg_key_id = 1976
   register_fake_response_from_file :get, "/api/appliances/#{@appliance_id}/gpg_keys/#{gpg_key_id}",
                                    'gpg_key.xml'
   register_fake_response_from_file :delete, "/api/appliances/#{@appliance_id}/gpg_keys/#{gpg_key_id}",
                                    'gpg_key.xml'
   assert StudioApi::Appliance::GpgKey.delete(gpg_key_id, :appliance_id => @appliance_id)
   res = StudioApi::Appliance.new(:id => @appliance_id).gpg_key gpg_key_id
   assert res.destroy
 end

 def test_add_gpg_key
   register_fake_response_from_file :post, "/api/appliances/#{@appliance_id}/gpg_keys?name=test&target=rpm&key=test",
                                    'gpg_key.xml'
   register_fake_response_from_file :post, "/api/appliances/#{@appliance_id}/gpg_keys?name=test&key=test&target=rpm",
                                    'gpg_key.xml'
   assert StudioApi::Appliance::GpgKey.create(@appliance_id, "test", "test")
   assert StudioApi::Appliance.new(:id => @appliance_id).add_gpg_key("test", "test")
 end
end
