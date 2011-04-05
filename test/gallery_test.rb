require 'rubygems'
require 'active_support'
$:.unshift File.join( File.dirname(__FILE__),'..','lib')
require 'studio_api/gallery'
require 'studio_api/connection'
require 'studio_api/generic_request'
require 'studio_api/util'
require 'active_resource/http_mock'
require 'mocha'
require 'test/unit'

class GalleryTest < Test::Unit::TestCase
  APPLIANCE_ID = 130166
  APPL_VERSION = "0.1.1"
  def respond_load name
    IO.read(File.join(File.dirname(__FILE__),"responses",name))
  end

  def setup
    @connection = StudioApi::Connection.new("test","test","http://localhost/api/")
    StudioApi::Util.configure_studio_connection @connection
  end

  def teardown
    Mocha::Mockery.instance.stubba.unstub_all
  end

  def test_find
    gallery_out = respond_load "gallery.xml"
    StudioApi::GenericRequest.any_instance.stubs(:get).with("/gallery/appliances?popular&per_page=10").returns(gallery_out)
    out = StudioApi::Gallery.find_appliance :popular, :per_page => 10
    assert_equal 10, out[:appliances].size
  end

  def test_appliance
    gallery_appliance_out = respond_load "gallery_appliance.xml"
    StudioApi::GenericRequest.any_instance.stubs(:get).with("/gallery/appliances/#{APPLIANCE_ID}/version/#{APPL_VERSION}").returns(gallery_appliance_out)
    out = StudioApi::Gallery.appliance APPLIANCE_ID, APPL_VERSION
    assert out
  end

  def test_gallery_appliance_versions
    versions_out = respond_load "versions.xml"
    StudioApi::GenericRequest.any_instance.stubs(:get).with("/gallery/appliances/#{APPLIANCE_ID}/versions").returns(versions_out)
    out = StudioApi::Gallery::Appliance.new(:id => APPLIANCE_ID).versions
    assert_equal 6,out.size
  end

end
