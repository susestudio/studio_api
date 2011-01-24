require 'rubygems'
require 'active_support'
$:.unshift File.join( File.dirname(__FILE__),'..','lib')
require 'studio_api/appliance'
require 'studio_api/connection'
require 'studio_api/generic_request'
require 'studio_api/util'
require 'active_resource/http_mock'
require 'mocha'
require 'test/unit'

class ApplianceTest < Test::Unit::TestCase
APPLIANCE_ID = 266657
REPO_ID = 6345
  def respond_load name
    IO.read(File.join(File.dirname(__FILE__),"responses",name))
  end

  def setup
    @connection = StudioApi::Connection.new("test","test","http://localhost/api/")
    StudioApi::Util.configure_studio_connection @connection
    appliances_out = respond_load "appliances.xml"
    appliance_out = respond_load "appliance.xml"
    status_out = respond_load "status.xml"
    repositories_out = respond_load "repositories.xml"
    gpg_keys_out = respond_load "gpg_keys.xml"
    gpg_key_out = respond_load "gpg_key.xml"
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/appliances", {"Authorization"=>"Basic dGVzdDp0ZXN0"},appliances_out,200
      mock.get "/api/appliances/#{APPLIANCE_ID}", {"Authorization"=>"Basic dGVzdDp0ZXN0"},appliance_out,200
      mock.get "/api/appliances/#{APPLIANCE_ID}/status", {"Authorization"=>"Basic dGVzdDp0ZXN0"},status_out,200
      mock.delete "/api/appliances/#{APPLIANCE_ID}", {"Authorization"=>"Basic dGVzdDp0ZXN0"},appliance_out,200 
      mock.get "/api/appliances/#{APPLIANCE_ID}/repositories", {"Authorization"=>"Basic dGVzdDp0ZXN0"},repositories_out,200
      mock.post "/api/appliances/#{APPLIANCE_ID}/cmd/add_repository?repo_id=#{REPO_ID}",{"Authorization"=>"Basic dGVzdDp0ZXN0"},repositories_out,200
      mock.post "/api/appliances/#{APPLIANCE_ID}/cmd/add_user_repository",{"Authorization"=>"Basic dGVzdDp0ZXN0"},repositories_out,200
      mock.get "/api/appliances/#{APPLIANCE_ID}/gpg_keys", {"Authorization"=>"Basic dGVzdDp0ZXN0"},gpg_keys_out,200
      mock.get "/api/appliances/#{APPLIANCE_ID}/gpg_keys/1976", {"Authorization"=>"Basic dGVzdDp0ZXN0"},gpg_key_out,200
      mock.delete "/api/appliances/#{APPLIANCE_ID}/gpg_keys/1976", {"Authorization"=>"Basic dGVzdDp0ZXN0"},gpg_key_out,200
    end
  end

  def teardown
    Mocha::Mockery.instance.stubba.unstub_all
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

  def test_maintenance_status
    status_out = respond_load "status-broken.xml"
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/appliances/#{APPLIANCE_ID}/status", {"Authorization"=>"Basic dGVzdDp0ZXN0"},status_out,200
    end
    res = StudioApi::Appliance.new(:id => APPLIANCE_ID)
    assert_equal "error", res.status.state
  end

  def test_clone
    appliance_out = respond_load "appliance.xml"
    StudioApi::GenericRequest.any_instance.stubs(:post).with("/appliances?clone_from=#{APPLIANCE_ID}",{}).returns(appliance_out).once
    assert StudioApi::Appliance.clone APPLIANCE_ID
  end

  def test_manifest
    manifest_out = respond_load "manifest.xml"
    StudioApi::GenericRequest.any_instance.stubs(:get).with("/appliances/#{APPLIANCE_ID}/software/manifest/vmx").returns(manifest_out).once
    assert StudioApi::Appliance.new(:id => APPLIANCE_ID).manifest_file "vmx"
  end

  def test_delete
    assert StudioApi::Appliance.delete APPLIANCE_ID
    assert StudioApi::Appliance.find(APPLIANCE_ID).destroy #same but different way
  end

  def test_repositories
    res = StudioApi::Appliance.new(:id => APPLIANCE_ID).repositories
    assert_equal 5,res.size
  end

  def test_repository_remove
    repositories_out = respond_load "repositories.xml"
    StudioApi::GenericRequest.any_instance.stubs(:post).with("/appliances/#{APPLIANCE_ID}/cmd/remove_repository?repo_id=#{REPO_ID}").returns(repositories_out)
    appliance = StudioApi::Appliance.new(:id => APPLIANCE_ID)
    assert appliance.remove_repository REPO_ID
    repo = appliance.repositories.detect { |r| r.id == REPO_ID.to_s}
    assert repo.destroy #another way to delete repository
  end

  def test_repository_add
    repositories_out = respond_load "repositories.xml"
    StudioApi::GenericRequest.any_instance.stubs(:post).with("/appliances/#{APPLIANCE_ID}/cmd/add_repository?repo_id=#{REPO_ID}").returns(repositories_out)
    assert StudioApi::Appliance.new(:id => APPLIANCE_ID).add_repository REPO_ID
  end

  def test_user_repository_add
    repositories_out = respond_load "repositories.xml"
    StudioApi::GenericRequest.any_instance.stubs(:post).with("/appliances/#{APPLIANCE_ID}/cmd/add_user_repository").returns(repositories_out)
    assert StudioApi::Appliance.new(:id => APPLIANCE_ID).add_user_repository
  end

  def test_user_repository_add
    users0 = respond_load "users_0.xml"
    users1 = respond_load "users_1.xml"
    users2 = respond_load "users_2.xml"
    StudioApi::GenericRequest.any_instance.stubs(:post).with("/appliances/#{APPLIANCE_ID}/sharing/test1").returns(users2).once
    StudioApi::GenericRequest.any_instance.stubs(:get).with("/appliances/#{APPLIANCE_ID}/sharing").returns(users1).once
    StudioApi::GenericRequest.any_instance.stubs(:delete).with("/appliances/#{APPLIANCE_ID}/sharing/test1").returns(users1).once
    assert_equal 1, StudioApi::Appliance.new(:id => APPLIANCE_ID).users.size
    assert_equal 2, StudioApi::Appliance.new(:id => APPLIANCE_ID).add_user("test1").size
    assert_equal 1, StudioApi::Appliance.new(:id => APPLIANCE_ID).remove_user("test1").size
    StudioApi::GenericRequest.any_instance.stubs(:get).with("/appliances/#{APPLIANCE_ID}/sharing").returns(users0).once
    assert_equal 0, StudioApi::Appliance.new(:id => APPLIANCE_ID).users.size
  end

  def test_selected_software
    software_out = respond_load "software.xml"
    StudioApi::GenericRequest.any_instance.stubs(:get).with("/appliances/#{APPLIANCE_ID}/software").returns(software_out).once
    res = StudioApi::Appliance.new(:id => APPLIANCE_ID).selected_software
    assert_equal 48,res.size
    assert res.any? {|r| r.is_a? StudioApi::Pattern }, "Pattern is not loaded"
    assert res.any? {|r| r.name = "sysvinit" && r.version == "2.86-200.1" }, "package with specified version not found"
  end

	def test_installed_software
    software_in_out = respond_load "software_installed.xml"
    StudioApi::GenericRequest.any_instance.stubs(:get).with("/appliances/#{APPLIANCE_ID}/software/installed?build_id=1").returns(software_in_out).once
    res = StudioApi::Appliance.new(:id => APPLIANCE_ID).installed_software :build_id => 1
    assert_equal 608,res.size
    assert res.any? {|r| r.is_a? StudioApi::Pattern }, "Pattern is not loaded"
		diag = res.find { |p| p.name == "3ddiag"}
		assert_equal "0.742-32.25",diag.version
		assert_equal 6347,diag.repository_id
  end

	def test_search_software
    software_se_out = respond_load "software_search.xml"
    StudioApi::GenericRequest.any_instance.stubs(:get).with("/appliances/#{APPLIANCE_ID}/software/search?q=qt").returns(software_se_out).once
    res = StudioApi::Appliance.new(:id => APPLIANCE_ID).search_software "qt"
    assert_equal 54,res.size
    assert res.any? {|r| r.is_a? StudioApi::Pattern }, "Pattern is not loaded"
		apport = res.find { |p| p.name == "apport-qt"}
		assert_equal "0.114-12.7.10",apport.version
		assert_equal 6347,apport.repository_id
	end

SOFTWARE_FAKE_RESPONSE= <<EOF
<success>
  <details>
    <status>
      <state>changed</state>
      <packages_added>13</packages_added>
      <packages_removed>0</packages_removed>
    </status>
  </details>
</success>
EOF
	def test_manipulate_with_packages_and_pattern
    StudioApi::GenericRequest.any_instance.stubs(:post).with("/appliances/#{APPLIANCE_ID}/cmd/add_package?name=3ddiag",:name => "3ddiag").returns(SOFTWARE_FAKE_RESPONSE).once
    StudioApi::GenericRequest.any_instance.stubs(:post).with("/appliances/#{APPLIANCE_ID}/cmd/remove_package?name=3ddiag",:name => "3ddiag").returns(SOFTWARE_FAKE_RESPONSE).once
    StudioApi::GenericRequest.any_instance.stubs(:post).with("/appliances/#{APPLIANCE_ID}/cmd/add_pattern?name=kde4", :name => "kde4").returns(SOFTWARE_FAKE_RESPONSE).once
    StudioApi::GenericRequest.any_instance.stubs(:post).with("/appliances/#{APPLIANCE_ID}/cmd/remove_pattern?name=kde4",:name => "kde4").returns(SOFTWARE_FAKE_RESPONSE).once
    StudioApi::GenericRequest.any_instance.stubs(:post).with("/appliances/#{APPLIANCE_ID}/cmd/ban_package?name=3ddiag",:name => "3ddiag").returns(SOFTWARE_FAKE_RESPONSE).once
    StudioApi::GenericRequest.any_instance.stubs(:post).with("/appliances/#{APPLIANCE_ID}/cmd/unban_package?name=3ddiag",:name => "3ddiag").returns(SOFTWARE_FAKE_RESPONSE).once
    appliance = StudioApi::Appliance.new(:id => APPLIANCE_ID)
		assert appliance.add_package "3ddiag"
		assert appliance.remove_package "3ddiag"
		assert appliance.add_pattern "kde4"
		assert appliance.remove_pattern "kde4"
		assert appliance.ban_package "3ddiag"
		assert appliance.unban_package "3ddiag"
  end

  def test_gpg_keys
    res = StudioApi::Appliance.new(:id => APPLIANCE_ID).gpg_keys
    assert_equal 3,res.size
  end

  def test_gpg_key
    res = StudioApi::Appliance.new(:id => APPLIANCE_ID).gpg_key 1976
    assert_equal 1976, res.id.to_i
    assert_equal "rpm", res.target
  end

  def test_delete_gpg_key
    assert StudioApi::Appliance::GpgKey.delete 1976, :appliance_id => APPLIANCE_ID 
    res = StudioApi::Appliance.new(:id => APPLIANCE_ID).gpg_key 1976
    assert res.destroy
  end

  def test_add_gpg_key
    gpg_key_out = respond_load "gpg_key.xml"
    StudioApi::GenericRequest.any_instance.stubs(:post).with("/appliances/#{APPLIANCE_ID}/gpg_keys?name=test&target=rpm&key=test",{}).returns(gpg_key_out)
    StudioApi::GenericRequest.any_instance.stubs(:post).with("/appliances/#{APPLIANCE_ID}/gpg_keys?name=test&key=test&target=rpm",{}).returns(gpg_key_out)
    assert StudioApi::Appliance::GpgKey.create APPLIANCE_ID, "test", "test"
    assert StudioApi::Appliance.new(:id => APPLIANCE_ID).add_gpg_key "test", "test"
  end
end
