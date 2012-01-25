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
    # @param (String,File) content of rpm as String or as opened file, in which case name is used as name
    # @param (#to_s) base_system for which is rpm compiled
    # @return [StudioApi::Rpm] uploaded RPM
    def self.upload content, base_system
      response = GenericRequest.new(studio_connection).post "/rpms?base_system=#{CGI.escape base_system.to_s}", :file => content
      if defined? ActiveModel #for rails3 we need persistent, otherwise delete method fail
        self.new Hash.from_xml(response)["rpm"],true
      else
        self.new Hash.from_xml(response)["rpm"]
      end
    end

    # Downloads file to specified path.
    # @return [String] content of rpm
    # @yield [tempfile] Access the tempfile from the block parameter
    # @yieldparam[tempfile Tempfile] Tempfile instance
    # @yieldreturn [nil] Tempfile gets closed when the block returns
    def content &block
      request = GenericRequest.new self.class.studio_connection
      path = "/rpms/#{id.to_i}/data"
      block_given? ? request.get_file(path, &block) : request.get(path)
    end
  end
end
