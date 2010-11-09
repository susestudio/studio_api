require "studio_api/studio_resource"

module StudioApi
  class Build < ActiveResource::Base
    extend StudioResource

    self.element_name = "build"
    undef_method :save
  end
end
