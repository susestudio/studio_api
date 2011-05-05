require 'test_helper'

class GenericRequestTest < Test::Unit::TestCase
  def setup
    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = false
    @connection = StudioApi::Connection.new(@@username, @@password,"http://localhost/api/")
    StudioApi::Build.studio_connection = @connection
    
    @test_response = "Test response"
  end

  def teardown
    FakeWeb.allow_net_connect = false
  end

  def test_get
    register_fake_response :get, "/api/test", @test_response
    assert_equal @test_response, StudioApi::GenericRequest.new(@connection).get("test")
  end

  def test_post
    register_fake_response :post, "/api/test", @test_response
    assert_equal @test_response,
      StudioApi::GenericRequest.new(@connection).post("test",:file => "/dev/zero")
  end

  def test_error_response
    error_response = <<-EOF
    <error>
    <code>invalid_base_system</code>
    <message>Invalid base system.</message>
    </error>
    EOF
    url = "http://#{@@username}:#{@@password}@localhost/api/test"
    FakeWeb.register_uri(:get, url, :body => error_response,
                         :status => ["503", "Unavailable"])

    assert_raises(ActiveResource::ServerError) do
      StudioApi::GenericRequest.new(@connection).get("test")
    end
  end

  def test_mime_type
    request = StudioApi::GenericRequest.new @connection
    assert_equal 'image/jpg', request.send(:mime_type, '/test/file.JPG')
    assert_equal 'image/jpg', request.send(:mime_type, 'test.jpeg')
    assert_equal 'image/gif', request.send(:mime_type, '/some_dir/some_file.GIF')
    assert_equal 'image/png', request.send(:mime_type, '/use_this.png')
  end

  def test_ssl_settings
    @connection = StudioApi::Connection.new("test","test","https://localhost",
                                            :ssl => { :verify_mode => OpenSSL::SSL::VERIFY_PEER,
                                            :ca_path => "/dev/null" })
    rq = StudioApi::GenericRequest.new @connection
    http_var = rq.instance_variable_get("@http")
    assert http_var.use_ssl?
    assert_equal OpenSSL::SSL::VERIFY_PEER, http_var.verify_mode
    assert_equal "/dev/null", http_var.ca_path
  end
end
