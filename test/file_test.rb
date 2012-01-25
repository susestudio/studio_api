require 'test_helper'

#FileTest cause collistion of names
class File1Test < Test::Unit::TestCase

  def setup
    @appliance_id=488
    @file_id = 1234765

    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = false
    @connection = StudioApi::Connection.new(@@username, @@password,"http://localhost/api/")
    StudioApi::File.studio_connection = @connection
  end

  def test_find
    register_fake_response_from_file :get, "/api/files?appliance_id=#{@appliance_id}",
                                     'files.xml'
    res = StudioApi::File.find :all, :params => { :appliance_id => @appliance_id }
    assert_equal 1, res.size
    assert_equal "http://susestudio.com/file/download/214486/1234765", res[0].download_url

    register_fake_response_from_file :get, "/api/files/#{@file_id}",
                                     'file.xml'
    res = StudioApi::File.find @file_id
    assert_equal "http://susestudio.com/file/download/214486/1234765", res.download_url
  end

  def test_delete
    register_fake_response_from_file :get, "/api/files/#{@file_id}",
                                     'file.xml'
    register_fake_response_from_file :delete, "/api/files/#{@file_id}",
                                     'file.xml'
    assert StudioApi::File.find(@file_id).destroy
    assert StudioApi::File.delete @file_id #different way
  end

  def test_update
    register_fake_response_from_file :get, "/api/files/#{@file_id}",
                                     'file.xml'
    register_fake_response_from_file :put, "/api/files/#{@file_id}",
                                     'file.xml'

    f = StudioApi::File.find(@file_id)
    f.path = "/tmp"
    assert f.save
  end

  def test_content
    file_name = 'file.xml'
    file_path = File.join File.dirname(__FILE__), 'responses'
    register_fake_response_from_file :get, "/api/files/#{@file_id}/data", file_name
    register_fake_response_from_file :get, "/api/files/#{@file_id}", file_name
    studio_file = StudioApi::File.find(@file_id)
    response = StringIO.new
    File.open(File.join(file_path, file_name), 'r') do |file|
      assert_equal studio_file.content, file.read
      studio_file.content do |body|
        response << body
      end
      file.rewind
      assert_equal file.read, response.string
    end
  end
end

