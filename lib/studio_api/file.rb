require "studio_api/studio_resource"
require "cgi"
module StudioApi
  # Represents overlay files which can be loaded to appliance.
  # 
  # Supports finding files, updating metadata, deleting, uploading and downloading.
  # 
  # @example Upload file Xorg.conf
  #   File.open ("/tmp/xorg.conf) { |file|
  #     StudioApi::File.upload file, 1234, :path => "/etc/X11", 
  #                         :filename => "Xorg.conf", :permissions => "0755",
  #                         :owner => "root"
  #   }
  class File < ActiveResource::Base
    extend StudioResource
    self.element_name = "file"

    # Downloads file to output. Allow downloading to stream or to path.
    # @param (#write,#to_s) stream for file or path where to store file
    def download (output)
      rq = GenericRequest.new self.class.studio_connection
      data = rq.get "/files/#{id.to_i}/data"
      if output.respond_to? :write #already stream
        output.write data
      else #file name
        ::File.open(output.to_s,"w") do |f|
          f.write data
        end
      end
    end

    # Uploads file to appliance
    # @param (#to_s) input_path to file which want to be uploaded
    # @param (#to_i) appliance_id id of appliance where to upload
    # @param (Hash<#to_s,#to_s>) options optional parameters, see API documentation
    def self.upload ( input, appliance_id, options = {})
      request_str = "files?appliance_id=#{appliance_id.to_i}"
      options.each do |k,v|
        request_str << "&#{CGI.escape k.to_s}=#{CGI.escape v}"
      end
      
      rq = GenericRequest.new self.class.studio_connection
      ::File.open(input_path, "r") do |input|
        rq.post request_str, :file => input
      end
    end

private 
    # file uses for update parameter put
    def new?
      false
    end
  end
end
