require "studio_api/studio_resource"
require 'cgi'


module StudioApi
  class Rpm < ActiveResource::Base
    extend StudioResource

    self.element_name = "rpm"
    def self.upload file_path, base_system
      ::File.open( file_path, "r" ) do |file|
        GenericRequest.new(studio_connection).post "/rpms?base_system=#{CGI.escape base_system}", :file => file
      end
    end

    # Warning: Read whole file to memory
    def self.download target_path, file_id
      data = GenericRequest.new(studio_connection).get "/rpms/#{file_id.to_i}/data"
      ::File.open(target_path, 'w') {|f| f.write(data) }
    end

    # instance know already studio_id of rpm
    def download target_path
      self.class.download target_path, id
    end
  end
end
