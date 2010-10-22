require "studio_api/resource"
require 'cgi'


module StudioApi
  class Rpm < ActiveResource::Base
    def self.upload file_path, base_system, connection = nil 
      ::File.new( path, "r" ) do |file|
        conn = connection || studio_connection
        GenericRequest.new(conn).post "/rpms?base_system=#{CGI.escape base_system}", :file => file
      end
    end

    # Warning: Read whole file to memory
    def self.download target_path, file_id, connection = nil
      conn = connection || studio_connection
      data = GenericRequest.new(conn).get "/rpms/#{file_id.to_i}/data"
      ::File.open(target_path, 'w') {|f| f.write(data) }
    end

    # instance know already studio_id of rpm
    def download target_path, connection = nil
      Rpm.download target_path, id, connection
    end
  end
end
