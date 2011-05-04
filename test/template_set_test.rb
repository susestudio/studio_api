require 'test_helper'

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
