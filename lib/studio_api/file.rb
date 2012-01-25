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
  #   File.open ("/tmp/xorg.conf") do |file|
  #     StudioApi::File.upload file, 1234, :path => "/etc/X11",
  #                         :filename => "Xorg.conf", :permissions => "0755",
  #                         :owner => "root"
  #   end
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
    # @return [String] content of file if no block
    # @return [nil] if block given
    # @yield [socket response segment] Read the Net::HTTPResponse segments
    # @yieldparam[body segment] buffered chunk of body
    # @yieldreturn [nil]
    def content &block
      rq = GenericRequest.new self.class.studio_connection
      path = "/files/#{id.to_i}/data"
      block_given? ? rq.get_file(path, &block) : rq.get(path)
    end

    # Overwritte file content and keep metadata ( of course without such things like size )
    # Immediatelly store new content
    # @param (File,#to_s) input new content for file as String or open file
    # @return [StudioApi::File] self with updated metadata
    def overwrite ( content )
      request_str = "/files/#{id.to_i}/data"
      rq = GenericRequest.new self.class.studio_connection
      response = rq.put request_str, :file => content
      load Hash.from_xml(response)["file"]
    end

    # Uploads file to appliance
    # @param (String,File) content as String or as opened File
    #   ( in this case its name is used as default for uploaded file name)
    # @param (#to_i) appliance_id id of appliance where to upload
    # @param (Hash<#to_s,#to_s>) options optional parameters, see API documentation
    # @return [StudioApi::File] metadata of uploaded file
    def self.upload ( content, appliance_id, options = {})
      request_str = "files?appliance_id=#{appliance_id.to_i}"
      options.each do |k,v|
        request_str << "&#{CGI.escape k.to_s}=#{CGI.escape v.to_s}"
      end
      rq = GenericRequest.new studio_connection
      response = rq.post request_str, :file => content
      if defined? ActiveModel #rails 3 and ActiveResource persistency
        File.new Hash.from_xml(response)["file"],true
      else
        File.new Hash.from_xml(response)["file"]
      end
    end

private
    # file uses for update parameter put
    # @private
    def new?
      false
    end
  end
end
