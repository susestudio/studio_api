require "studio_api/resource"

require "uri"

module StudioApi
  class RunningBuild < Resource
    self.element_name = "running_build"

    alias_method :cancel, :destroy

private
    #overwrite create as studio doesn't interact well with enclosed parameters
    def create
      request_str = collection_path
      request_str << "?appliance_id=#{attributes.delete("appliance_id").to_i}"
      attributes.each do |k,v|
        request_str << "&#{URI.escape k.to_s}=#{URI.escape v.to_s}"
      end
      connection.post(request_str,"",self.class.headers).tap do |response|
        load_attributes_from_response response
      end
    end
  end
end
