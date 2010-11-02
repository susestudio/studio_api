require 'rubygems'
require 'mocha'
require 'test/unit'
$:.unshift File.join( File.dirname(__FILE__),'..','lib')
require 'studio_api/generic_request'
require 'studio_api/connection'

class GenericRequestTest < Test::Unit::TestCase
  def setup
    @connection = StudioApi::Connection.new("test","test","http://localhost")
  end

  def teardown
    Mocha::Mockery.instance.stubba.unstub_all
  end

  def test_get
    test_response = "Test response"
    StudioApi::GenericRequest.any_instance.stubs(:do_request).returns test_response
    assert_equal test_response, StudioApi::GenericRequest.new(@connection).get("test")
  end

  def test_post
    test_response = "Test response"
    StudioApi::GenericRequest.any_instance.stubs(:do_request).returns test_response
    assert_equal test_response, StudioApi::GenericRequest.new(@connection).post("test",:file => "/dev/zero")
  end

  def test_mime_type
    request = StudioApi::GenericRequest.new @connection
    assert_equal 'image/jpg', request.send(:mime_type, '/test/file.JPG')
    assert_equal 'image/jpg', request.send(:mime_type, 'test.jpeg')
    assert_equal 'image/gif', request.send(:mime_type, '/some_dir/some_file.GIF')
    assert_equal 'image/png', request.send(:mime_type, '/use_this.png')
  end
end
