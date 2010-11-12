require "studio_api/studio_resource"

module StudioApi
  # Represents template sets. It is usefull when clone appliance.
  # allows only reading
  class TemplateSet < ActiveResource::Base
    extend StudioResource
    undef_method :save
    undef_method :destroy
    element_name = "template_set"
  end
end
