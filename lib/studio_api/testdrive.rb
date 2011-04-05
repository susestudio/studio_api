require "studio_api/studio_resource"

module StudioApi
  class Testdrive < ActiveResource::Base
    # Testdrives
    #
    # @example Run a build in testdrive
    #   StudioApi::Testdrive.create(:build_id => 1234)
    extend StudioResource

    self.element_name = "testdrive"
    undef_method :delete

private
    #overwrite create as studio doesn't interact well with enclosed parameters
    def create
      request_str = collection_path
      request_str << "?build_id=#{attributes.delete("build_id").to_i}"
      attributes.each do |k,v|
        request_str << "&#{CGI.escape k.to_s}=#{CGI.escape v.to_s}"
      end
      connection.post(request_str,"",self.class.headers).tap do |response|
        load_attributes_from_response response
      end
    end
  end
end
