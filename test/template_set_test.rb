require 'rubygems'
require 'active_support'
require 'active_resource/http_mock'
require 'mocha'
require 'test/unit'
require 'tempfile'
$:.unshift File.join( File.dirname(__FILE__), '..', 'lib')
require 'studio_api/template_set'
require 'studio_api/connection'
require 'studio_api/generic_request'

class TemplateSetTest < Test::Unit::TestCase

  def respond_load name
    IO.read(File.join(File.dirname(__FILE__), "responses", name))
  end

  def setup
    @connection = StudioApi::Connection.new("test", "test", "http://localhost")
    StudioApi::TemplateSet.studio_connection = @connection

    template_sets_out = respond_load "template_sets.xml"

    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/template_sets", {"Authorization"=>"Basic dGVzdDp0ZXN0"}, template_sets_out, 200
    end
  end

  def test_find
    res = StudioApi::TemplateSet.find :all
    assert_equal 6, res.size
    assert_equal 42, res[0].template.size
  end

end
