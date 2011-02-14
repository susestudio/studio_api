require "studio_api/studio_resource"
require "studio_api/generic_request"
require "studio_api/comment"
require "xmlsimple"
require "fileutils"
require 'cgi'

module StudioApi
  class Gallery < ActiveResource::Base
    extend StudioApi::StudioResource
    self.element_name = "gallery"

    class Appliance < ActiveResource::Base
      extend StudioApi::StudioResource

      # Gets rating details as hash
      # #return[Hash] TODO
      def rating
        request_str = "/gallery/appliances/#{id.to_i}/rating"
        response = GenericRequest.new(self.class.studio_connection).get request_str
        XmlSimple.xml_in(response, "ForceArray" => false)["appliance"]
      end

      # Posts own rating of appliance
      # @param[#to_i] value in range 0..5
      # @return[Hash] TODO
      def rate value
        request_str = "/gallery/appliances/#{id.to_i}/rating?rating=#{value.to_i}"
        response = GenericRequest.new(self.class.studio_connection).post request_str
        XmlSimple.xml_in(response, "ForceArray" => false)["appliance"]
      end

      # Modifies appliance release notes
      # @param[String] text of release notes
      def release_notes= (text)
        request_str = "/gallery/appliances/#{id.to_i}/version/#{CGI.escape version.to_s}"
        response = GenericRequest.new(studio_connection).put request_str, :__raw => release_notes
      end

      # Removes appliance from gallery
      def unpublish
        request_str = "/gallery/appliances/#{id.to_i}/version/#{CGI.escape version.to_s}"
        response = GenericRequest.new(studio_connection).delete request_str
      end

      # Gets all available versions of appliance in gallery
      def versions
        request_str = "/gallery/appliances/#{id.to_i}/versions"
        response = GenericRequest.new(self.class.studio_connection).get request_str
        tree = XmlSimple.xml_in response, "ForceArray" => ["version"]
        return tree["appliance"]["versions"]["version"]
      end

      # Retrieves information about software used to create appliance
      def software options = {}
        request_str = "/gallery/appliances/#{id.to_i}/software"
        request_str = Util.add_options request_str, options
        response = GenericRequest.new(self.class.studio_connection).get request_str
        #TODO parse response to something usefull
      end

      # Retrieves content of logo image
      def logo
        request_str = "/gallery/appliances/#{id.to_i}/logo"
        response = GenericRequest.new(self.class.studio_connection).get request_str
      end

      # Retrieves content of background image
      def background
        request_str = "/gallery/appliances/#{id.to_i}/background"
        response = GenericRequest.new(self.class.studio_connection).get request_str
      end

      # Starts testdrive and gets information how to use it
      def testdrive options = {}
        request_str = "/gallery/appliances/#{id.to_i}/testdrive"
        request_str = Util.add_options request_str, options
        response = GenericRequest.new(self.class.studio_connection).post request_str
        tree = XmlSimple.xml_in response, "ForceArray" => false
        tree["testdrive"]
      end

      # Retrieves all comments to appliance
      # @return [Array[StudioApi::Comment]] list of comments
      def comments
        request_str = "/gallery/appliances/#{id.to_i}/comments"
        response = GenericRequest.new(self.class.studio_connection).get request_str
        tree = XmlSimple.xml_in response, "ForceArray" => ["comment"]
        tree["appliance"]["comments"]["comment"].collect do |c|
          Comment.parse(self,c)
        end
      end

      # Adds new comment to appliance
      def post_comment text, options={}
        request_str = "/gallery/appliances/#{id.to_i}/comments"
        request_str = Util.add_options request_str, options
        response = GenericRequest.new(self.class.studio_connection).post request_str, :__raw => text
        tree = XmlSimple.xml_in response, "ForceArray" => ["comment"]
        tree["appliance"]["comments"]["comment"].collect do |c|
          Comment.parse(self,c)
        end
      end
    end

    # Searches for appliance with options specified in API help
    # @see http://susestudio.com/help/api/v2#65 for search specification
    # @param [#to_s] type type of search
    # @param [Hash[#to_s,#to_s]] options additional options
    # @return TODO
    def self.find_appliance type,options={}
      request_str = "/gallery/appliances?#{CGI.escape type.to_s}"
      request_str = Util.add_options request_str, options, false
      response = GenericRequest.new(studio_connection).get request_str
      tree = XmlSimple.xml_in(response,"ForceArray" => ["appliance"])["appliances"]
      count = tree["pages"].to_i
      page = tree["current_page"].to_i
      appliances = tree["appliance"].reduce([]) do |acc,appl|
        appl.each { |k,v| appl[k] = nil if v.empty? } #avoid empty string, array or hash
        gappl = Gallery::Appliance.dup
        gappl.studio_connection = studio_connection
        acc << gappl.new(appl)
      end
      return :count => count, :page => page, :appliances => appliances
    end

    def self.appliance id, version = nil
      request_str = "/gallery/appliances/#{id.to_i}"
      request_str << "/version/#{CGI.escape version.to_s}" if version
      response = GenericRequest.new(studio_connection).get request_str
      tree = XmlSimple.xml_in(response,"ForceArray" => ["format","account"])["appliance"]
      Gallery::Appliance.new tree
    end

    def self.publish_appliance id, version, release_notes
      request_str = "/gallery/appliances/#{id.to_i}/version/#{CGI.escape version.to_s}"
      response = GenericRequest.new(studio_connection).post request_str, :__raw => release_notes
    end
  end
end
