require "studio_api/resource"
module StudioApi
  class Appliance < Resource
    class Status < Resource
    end
  def status
    Status.set_connection self.class.studio_connection
    Status.find :one, :from => "/appliances/#{id.to_i}/status"
  end
  end
end
