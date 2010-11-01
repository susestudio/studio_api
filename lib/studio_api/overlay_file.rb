require "cgi"
require "studio_api/generic_request"
require "xmlsimple"

module StudioApi
  class OverlayFile

    ATTRIBUTES = [:id, :filename, :path, :owner, :group, :permissions, :enabled, :download_url]

    ATTRIBUTES.each {|a| attr_accessor a }

    def initialize connection
      @studio_connection = connection
    end

    def delete
      request_str = "files/#{id.to_i}"
      GenericRequest.new(@studio_connection).delete(request_str)
    end

    def self.find_all (connection, appliance_id)
      request_str = "files?appliance_id=#{appliance_id.to_i}"
      response = GenericRequest.new(connection).get(request_str)
      response = XmlSimple.xml_in response
      ret = []
      response["file"].each do |f|
        ret << create_from_value(connection, f)
      end
      ret
    end

    def self.find (connection, file_id)
      request_str = "files/#{file_id.to_i}"
      response = GenericRequest.new(connection).get(request_str)
      response = XmlSimple.xml_in response
      create_from_value(connection, response)
    end

    def download (output)
      OverlayFile.download(@studio_connection, output, id)
    end

    def self.upload ( connection, input_path, appliance_id, options = {})
      request_str = "files?appliance_id=#{appliance_id.to_i}"
      options.each do |k,v|
        request_str << "&#{CGI.escape k.to_s}=#{CGI.escape v}"
      end
      rq = GenericRequest.new connection
      rq.post request_str, input_path
    end

    def self.download (connection, output, file_id)
      rq = GenericRequest.new connection
      data = rq.get "/files/#{file_id.to_i}/data"
      if output.respond_to? :write #already stream
        output.write data
      else #file name
        ::File.open(output.to_s,"w") do |f|
          f.write data
        end
      end
    end

  private
    def self.create_from_value (connection, input)
      of = OverlayFile.new connection
      ATTRIBUTES.each do |attr|
        value = input[attr.to_s]
        if value
          of.instance_variable_set "@#{attr}", value.first
        end
      end
      of
    end
  end
end
