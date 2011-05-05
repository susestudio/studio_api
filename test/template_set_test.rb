require 'test_helper'

class TemplateSetTest < Test::Unit::TestCase

  def setup
    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = false
    @connection = StudioApi::Connection.new(@@username, @@password,"http://localhost/api/")
    StudioApi::TemplateSet.studio_connection = @connection
  end

  def teardown
    FakeWeb.allow_net_connect = false
  end

  def test_find
    register_fake_response_from_file :get, "/api/template_sets",
                                     'template_sets.xml'
    res = StudioApi::TemplateSet.find :all
    assert_equal 6, res.size
    assert_equal 42, res[0].template.size
  end

end
