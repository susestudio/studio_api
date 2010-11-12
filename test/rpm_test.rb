require 'rubygems'
require 'active_support'
require 'active_resource/http_mock'
require 'mocha'
require 'test/unit'
require 'tempfile'
$:.unshift File.join( File.dirname(__FILE__), '..', 'lib')
require 'studio_api/rpm'
require 'studio_api/connection'
require 'studio_api/generic_request'

class RpmTest < Test::Unit::TestCase
  APPLIANCE_ID = 269186
  RPM_ID = 27653

  def respond_load name
    IO.read(File.join(File.dirname(__FILE__), "responses", name))
  end

  def setup
    @connection = StudioApi::Connection.new("test", "test", "http://localhost")
    StudioApi::Rpm.studio_connection = @connection

    rpms_out = respond_load "rpms.xml"
    rpm_out = respond_load "rpm.xml"

    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/rpms?base_system=sle11_sp1", {"Authorization"=>"Basic dGVzdDp0ZXN0"}, rpms_out, 200
      mock.get "/rpms/#{RPM_ID}", {"Authorization"=>"Basic dGVzdDp0ZXN0"}, rpm_out, 200
      mock.delete "/rpms/#{RPM_ID}", {"Authorization"=>"Basic dGVzdDp0ZXN0"}, rpm_out, 200
    end
  end

  def test_find
    res = StudioApi::Rpm.find :all, :params => {:base_system => "sle11_sp1"}
    assert_equal 48, res.size
    res = StudioApi::Rpm.find RPM_ID
    assert "false", res.archive
  end

  def test_delete
    rpm = StudioApi::Rpm.find RPM_ID
    assert rpm.destroy
    assert StudioApi::Rpm.delete RPM_ID
  end

TEST_STRING = "My lovely testing string\n Doodla da da da nicht"
  def test_download
    file = Tempfile.new("/tmp")
    StudioApi::GenericRequest.any_instance.stubs(:get).with("/rpms/#{RPM_ID}/data").returns(TEST_STRING)
    StudioApi::Rpm.new(:id=> RPM_ID).download file.path
    File.open(file.path) { |f| assert_equal TEST_STRING,f.read }
  end

  def test_upload
    rpm_out = respond_load "rpm.xml"
    file = Tempfile.new("/tmp")
    file.write TEST_STRING
    file.close
    StudioApi::GenericRequest.any_instance.stubs(:post).returns(rpm_out)
    assert StudioApi::Rpm.upload(file.path, "SLE11")
  end

end
