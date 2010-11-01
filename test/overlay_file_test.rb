require 'rubygems'
require 'test/unit'
require 'mocha'
$:.unshift File.join( File.dirname(__FILE__),'..','lib')
require 'studio_api/overlay_file'
require 'studio_api/connection'

class OverlayFileTest < Test::Unit::TestCase
  def setup
    @connection = StudioApi::Connection.new("test","test","http://localhost")
  end

  def test_find_all
    find_all_response = IO.read( File.join( File.dirname(__FILE__),"responses","files.xml"))
    StudioApi::GenericRequest.any_instance.stubs(:get).with("files?appliance_id=1").returns(find_all_response).once
    ofiles = StudioApi::OverlayFile.find_all @connection, 1
    assert_equal 2, ofiles.size
    assert ofiles.any? {|f| f.id.to_s == "22" }
  end

  def test_find
    find_response = IO.read( File.join( File.dirname(__FILE__),"responses","file.xml"))
    StudioApi::GenericRequest.any_instance.stubs(:get).with("files/21").returns(find_response).once
    ofile = StudioApi::OverlayFile.find @connection, 21
    assert_equal "21", ofile.id.to_s
  end
end
