require "studio_api/studio_resource"
require "cgi"
module StudioApi
  # Represents overlay files which can be loaded to appliance.
  # 
  # Supports finding files for appliance, updating metadata, deleting, uploading and downloading.
  # 
  # @example Find files for appliance
  # StudioApi::File.find :all, :params => { :appliance_id => 1234 }
  #
  # @example Upload file Xorg.conf
  #   File.open ("/tmp/xorg.conf) { |file|
  #     StudioApi::File.upload file, 1234, :path => "/etc/X11", 
  #                         :filename => "Xorg.conf", :permissions => "0755",
  #                         :owner => "root"
  #   }
  #
  # @example Update metadata
  # file = StudioApi::File.find 1234
  # file.owner = "root"
  # file.path = "/etc"
  # file.filename = "pg.conf"
  # file.save

  class File < ActiveResource::Base
    extend StudioResource
    self.element_name = "file"

    # Downloads file to output. Allow downloading to stream or to path.
    # @param (#write,#to_s) stream for file or path where to store file
    # @return (Fixnum) number of bytes written
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
    # @return [StudioApi::File] metadata of uploaded file
    def self.upload ( input, appliance_id, options = {})
      request_str = "files?appliance_id=#{appliance_id.to_i}"
      options.each do |k,v|
        request_str << "&#{CGI.escape k.to_s}=#{CGI.escape v}"
      end
      rq = GenericRequest.new studio_connection
      response = rq.post request_str, :file => input
      File.new Hash.from_xml(response)["file"]
    end

private 
    # file uses for update parameter put
    # @private
    def new?
      false
    end
  end
end
