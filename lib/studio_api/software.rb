require "studio_api/resource"

module StudioApi
  class Software < Resource
    self.prefix = "/appliances/:appliance_id/"
  end
end
