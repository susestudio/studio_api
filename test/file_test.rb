require 'test_helper'

#FileTest cause collistion of names
class File1Test < Test::Unit::TestCase
  APPLIANCE_ID=488
  FILE_ID = 1234765

  def respond_load name
    IO.read(File.join(File.dirname(__FILE__),"responses",name))
  end

  def setup
    @connection = StudioApi::Connection.new("test","test","http://localhost")
    StudioApi::File.studio_connection = @connection
    files_out = respond_load "files.xml"
    file_out = respond_load "file.xml"
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/files?appliance_id=#{APPLIANCE_ID}", {"Authorization"=>"Basic dGVzdDp0ZXN0"},files_out,200
      mock.get "/files/#{FILE_ID}", {"Authorization"=>"Basic dGVzdDp0ZXN0"},file_out,200
      mock.delete "/files/#{FILE_ID}", {"Authorization"=>"Basic dGVzdDp0ZXN0"},file_out,200
      mock.put "/files/#{FILE_ID}", {"Authorization"=>"Basic dGVzdDp0ZXN0"},file_out,200
    end
  end

  def test_find
    res = StudioApi::File.find :all, :params => { :appliance_id => APPLIANCE_ID }
    assert_equal 1, res.size
    assert_equal "http://susestudio.com/file/download/214486/1234765", res[0].download_url
    res = StudioApi::File.find FILE_ID
    assert_equal "http://susestudio.com/file/download/214486/1234765", res.download_url
  end

  def test_delete
    assert StudioApi::File.find(FILE_ID).destroy
    assert StudioApi::File.delete FILE_ID #different way
  end

  def test_update
    f = StudioApi::File.find(FILE_ID)
    f.path = "/tmp"
    assert f.save
  end
end

