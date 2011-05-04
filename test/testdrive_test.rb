require 'rubygems'
require 'active_support'
require 'active_resource/http_mock'
require 'mocha'
require 'test/unit'
$:.unshift File.join( File.dirname(__FILE__), '..', 'lib')
require 'studio_api/testdrive'
require 'studio_api/connection'

class TestdriveTest < Test::Unit::TestCase
  BUILD_ID = 12345

  def respond_load name
    IO.read(File.join(File.dirname(__FILE__), "responses", name))
  end

  def setup
    @connection = StudioApi::Connection.new("test", "test", "http://localhost")
    StudioApi::Testdrive.studio_connection = @connection

    testdrives_out = respond_load "testdrives.xml"
    testdrive_out = respond_load "testdrive.xml"

    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/testdrives", {"Authorization"=>"Basic dGVzdDp0ZXN0"}, testdrives_out, 200
      mock.post "/testdrives?build_id=#{BUILD_ID}", {"Authorization"=>"Basic dGVzdDp0ZXN0"}, testdrive_out, 200
    end
  end

  def test_find
    res = StudioApi::Testdrive.find :all
    assert_equal 1, res.size
  end

  def test_new
    assert StudioApi::Testdrive.new(:build_id => BUILD_ID).save
  end
end
