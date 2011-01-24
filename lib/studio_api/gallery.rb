require "studio_api/studio_resource"
require "studio_api/generic_request"
require "xmlsimple"
require "fileutils"
require 'cgi'

module StudioApi
  class Gallery < ActiveResource::Base
    extend StudioApi::StudioResource
    self.element_name = "gallery"
    
    class Appliance < ActiveResource::Base
      extend StudioApi::StudioResource
    end

    def self.find_appliance type,options={}
      request_str = "/gallery/appliances?#{CGI.escape type.to_s}"
      request_str = Util.add_options request_str, options, false
      response = GenericRequest.new(studio_connection).get request_str
      tree = XmlSimple.xml_in(response,"ForceArray" => ["appliance"])["appliances"]
      count = tree["pages"].to_i
      page = tree["current_page"].to_i
      appliances = tree["appliance"].reduce([]) do |acc,appl|
        appl.each { |k,v| appl[k] = nil if v.empty? } #avoid empty string, array or hash
        acc << Gallery::Appliance.new(appl)
      end
      return :count => count, :page => page, :appliances => appliances
    end

    def self.appliance id, version = nil
      request_str = "/gallery/appliances/#{id.to_i}"
      request_str += "/version/#{CGI.escape version.to_s}" if version
      response = GenericRequest.new(studio_connection).get request_str
      tree = XmlSimple.xml_in(response,"ForceArray" => ["format","account"])["appliance"]
      Gallery::Appliance.new tree
    end
  end
end
