require "studio_api/resource"

module StudioApi
  class Build < Resource
    self.element_name = "build"
    undef_method :save
  end
end
