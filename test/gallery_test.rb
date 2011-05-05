require 'test_helper'

class GalleryTest < Test::Unit::TestCase
  def setup
    @appliance_id = 130166
    @appliance_version = "0.1.1"

    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = false
    @connection = StudioApi::Connection.new(@@username, @@password,"http://localhost/api/")
    StudioApi::Util.configure_studio_connection @connection
  end

  def teardown
    FakeWeb.allow_net_connect = false
  end

  def test_find
    register_fake_response_from_file :get, "/api/gallery/appliances?popular&per_page=10",
                                     'gallery.xml'
    out = StudioApi::Gallery.find_appliance :popular, :per_page => 10
    assert_equal 10, out[:appliances].size
  end

  def test_appliance
    register_fake_response_from_file :get, "/api/gallery/appliances/#{@appliance_id}/version/#{@appliance_version}",
                                     'gallery_appliance.xml'
    out = StudioApi::Gallery.appliance @appliance_id, @appliance_version
    assert out
  end

  def test_gallery_appliance_versions
    register_fake_response_from_file :get, "/api/gallery/appliances/#{@appliance_id}/versions",
                                     'versions.xml'
    out = StudioApi::Gallery::Appliance.new(:id => @appliance_id).versions
    assert_equal 6,out.size
  end

end
