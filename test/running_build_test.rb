require 'rubygems'
require 'active_support'
require 'active_resource/http_mock'
require 'mocha'
require 'test/unit'
$:.unshift File.join( File.dirname(__FILE__), '..', 'lib')
require 'studio_api/running_build'
require 'studio_api/connection'

class RunningBuildTest < Test::Unit::TestCase
  BUILD_ID = 529783
  APPLIANCE_ID = 269186

  def respond_load name
    IO.read(File.join(File.dirname(__FILE__), "responses", name))
  end

  def setup
    @connection = StudioApi::Connection.new("test", "test", "http://localhost")
    StudioApi::RunningBuild.set_connection @connection

    running_builds_out = respond_load "running_builds.xml"
    running_build_out = respond_load "running_build.xml"

    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/running_builds?appliance_id=#{APPLIANCE_ID}", {"Authorization"=>"Basic dGVzdDp0ZXN0"}, running_builds_out, 200
      mock.get "/running_builds/#{BUILD_ID}", {"Authorization"=>"Basic dGVzdDp0ZXN0"}, running_build_out, 200
    end
  end

  def test_find
    res = StudioApi::RunningBuild.find :all, :params => {:appliance_id => APPLIANCE_ID}
    assert_equal 3, res.size
    res = StudioApi::RunningBuild.find BUILD_ID
    assert_equal BUILD_ID, res.id.to_i
  end
end
