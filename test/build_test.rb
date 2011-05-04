require 'test_helper'

class BuildTest < Test::Unit::TestCase
  BUILD_ID = 509559
  APPLIANCE_ID = 269186

  def respond_load name
    IO.read(File.join(File.dirname(__FILE__), "responses", name))
  end

  def setup
    @connection = StudioApi::Connection.new("test", "test", "http://localhost")
    StudioApi::Build.studio_connection = @connection

    builds_out = respond_load "builds.xml"
    build_out = respond_load "build.xml"

    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/builds?appliance_id=#{APPLIANCE_ID}", {"Authorization"=>"Basic dGVzdDp0ZXN0"}, builds_out, 200
      mock.get "/builds/#{BUILD_ID}", {"Authorization"=>"Basic dGVzdDp0ZXN0"}, build_out, 200
      mock.delete "/builds/#{BUILD_ID}", {"Authorization"=>"Basic dGVzdDp0ZXN0"}, build_out, 200
    end
  end

  def test_find
    res = StudioApi::Build.find :all, :params => {:appliance_id => APPLIANCE_ID}
    assert_equal 1, res.size
    res = StudioApi::Build.find BUILD_ID
    assert_equal "true", res.expired
  end

  def test_delete
    build = StudioApi::Build.find BUILD_ID
    assert build.destroy
    assert StudioApi::Build.delete BUILD_ID
  end

end
