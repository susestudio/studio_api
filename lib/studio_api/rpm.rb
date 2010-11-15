require "studio_api/studio_resource"
require 'cgi'

module StudioApi
  # Represents Additional rpms which can user upload to studio.
  # 
  # Allows uploading, downloading, listing (via find) and deleting
  # 
  # @example Delete own rpm
  #   rpms = StudioApi::Rpm.find :all, :params => { :base_system => "SLE11" }
  #   my_pac = rpms.find {|r| r.filename =~ /my_pac/ }
  #   my_pac.delete
  class Rpm < ActiveResource::Base
    extend StudioResource
    undef_method :save

    self.element_name = "rpm"
    # Upload file to studio account (user repository)
    # @param (String) file_path to rpm which is uploaded
    # @param (#to_s) base_system for which is rpm compiled
    # @return [StudioApi::Rpm] uploaded RPM
    def self.upload file_path, base_system
      ::File.open( file_path, "r" ) do |file|
        response = GenericRequest.new(studio_connection).post "/rpms?base_system=#{CGI.escape base_system.to_s}", :file => file
        self.new Hash.from_xml(response)["rpm"]
      end
    end

    # Downloads file to specified path.
    #
    # Warning: Read whole file to memory
    # @param (String) target_path where save downloaded file
    # @return [Fixnum] number of written bytes
    def download target_path
      data = GenericRequest.new(self.class.studio_connection).get "/rpms/#{id.to_i}/data"
      ::File.open(target_path, 'w') {|f| f.write(data) }
    end
  end
end
