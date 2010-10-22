module StudioApi
  class Software < Resource
    def self.set_appliance_id id
      self.prefix = self.site.path+"/appliances/#{id.to_i}/"
      @appliance_id = id
    end
  end
end
