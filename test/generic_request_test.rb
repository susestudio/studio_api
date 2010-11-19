require 'rubygems'
require 'mocha'
require 'test/unit'
$:.unshift File.join( File.dirname(__FILE__),'..','lib')
require 'studio_api/generic_request'
require 'studio_api/connection'
require 'net/http'

class GenericRequestTest < Test::Unit::TestCase
  def setup
    Mocha::Mockery.instance.stubba.unstub_all
    @connection = StudioApi::Connection.new("test","test","http://localhost")
  end

  def teardown
    Mocha::Mockery.instance.stubba.unstub_all
  end

ERROR_RESPONSE = <<EOF
<error>
<code>invalid_base_system</code>
<message>Invalid base system.</message>
</error>
EOF
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

  def test_error_response
    response = Net::HTTPServiceUnavailable.new("4.1",503,"Unnavailable")
    response.instance_variable_set "@body", ERROR_RESPONSE
    response.instance_variable_set "@read", true #avoid real reading
    Net::HTTP.any_instance.stubs(:request).returns(response)
    rq = StudioApi::GenericRequest.new(@connection)
    http_var = rq.instance_variable_get("@http")
    def http_var.start
      yield
    end
    assert_raises(ActiveResource::ServerError) { rq.get("test") }
  end

  def test_mime_type
    request = StudioApi::GenericRequest.new @connection
    assert_equal 'image/jpg', request.send(:mime_type, '/test/file.JPG')
    assert_equal 'image/jpg', request.send(:mime_type, 'test.jpeg')
    assert_equal 'image/gif', request.send(:mime_type, '/some_dir/some_file.GIF')
    assert_equal 'image/png', request.send(:mime_type, '/use_this.png')
  end

  def test_ssl_settings
    @connection = StudioApi::Connection.new("test","test","https://localhost",:ssl => { :verify_mode => OpenSSL::SSL::VERIFY_PEER, :ca_path => "/dev/null" })
    rq = StudioApi::GenericRequest.new @connection
    http_var = rq.instance_variable_get("@http")
    assert http_var.use_ssl?
    assert_equal OpenSSL::SSL::VERIFY_PEER, http_var.verify_mode
    assert_equal "/dev/null", http_var.ca_path
  end
end
