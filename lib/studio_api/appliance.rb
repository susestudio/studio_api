require "studio_api/resource"
module StudioApi
  class Appliance < Resource
    class Status < Resource
    end

    def status
      Status.set_connection self.class.studio_connection
      Status.find :one, :from => "/appliances/#{id.to_i}/status"
    end

    def clone options={}
      options[:appliance_id] = id
      post('',options)
    end

    def self.clone appliance_id, options={}
      self.new(:id => appliance_id).clone options
    end

#internal overwrite of ActiveResource::Base methods
    def new?
      false #Appliance has only POST method
    end

#studio post method for clone is special, as it doesn't have element inside
    def custom_method_element_url(method_name,options = {})
      prefix_options, query_options = split_options(options)
      "#{self.class.prefix(prefix_options)}#{self.class.collection_name}#{self.class.send :query_string,query_options}"
    end
  end
end
