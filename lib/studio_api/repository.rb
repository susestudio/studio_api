require "studio_api/resource"
module StudioApi
  class Repository < Resource
    self.prefix = "/appliances/:appliance_id/"
  end
end
