require 'test_helper'

class RpmTest < Test::Unit::TestCase

  def setup
    @appliance_id = 269186
    @rpm_id = 27653
    @rpm_data = "My lovely testing string\n Doodla da da da nicht"

    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = false
    @connection = StudioApi::Connection.new(@@username, @@password,"http://localhost/api/")
    StudioApi::Rpm.studio_connection = @connection
  end

  def teardown
    FakeWeb.allow_net_connect = false
  end

  def test_find
    register_fake_response_from_file :get, "/api/rpms?base_system=sle11_sp1",
                                     'rpms.xml'
    res = StudioApi::Rpm.find :all, :params => {:base_system => "sle11_sp1"}
    assert_equal 48, res.size

    register_fake_response_from_file :get, "/api/rpms/#{@rpm_id}",
                                     'rpm.xml'
    res = StudioApi::Rpm.find @rpm_id
    assert "false", res.archive
  end

  def test_delete
    register_fake_response_from_file :get, "/api/rpms/#{@rpm_id}",
                                     'rpm.xml'
    register_fake_response_from_file :delete, "/api/rpms/#{@rpm_id}",
                                     'rpm.xml'
    rpm = StudioApi::Rpm.find @rpm_id
    assert rpm.destroy
    assert StudioApi::Rpm.delete @rpm_id
  end

  def test_download
    register_fake_response :get, "/api/rpms/#{@rpm_id}/data", @rpm_data
    assert_equal @rpm_data, StudioApi::Rpm.new(:id=> @rpm_id).content
  end

   def test_upload
     register_fake_response_from_file :post, "/api/rpms?base_system=SLE11",
                                     'rpm.xml'
     assert StudioApi::Rpm.upload(@rpm_data, "SLE11")
   end

   def test_download_with_block
     register_fake_response :get, "/api/rpms/#{@rpm_id}/data", @rpm_data
     file_content = nil
     rpm = StudioApi::Rpm.new(:id=> @rpm_id).content {|f| f.rewind; file_content = f.read }
     assert_equal @rpm_data, file_content
   end


end
