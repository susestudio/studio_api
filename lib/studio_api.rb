#
#  Copyright (c) 2009 Novell, Inc.
#  All Rights Reserved.
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public License as
#  published by the Free Software Foundation; version 2.1 of the license.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.   See the
#  GNU Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public License
#  along with this library; if not, contact Novell, Inc.
#
#  To contact Novell about this file by physical or electronic mail,
#  you may find current contact information at www.novell.com

require 'xmlsimple'
require 'uri'
require 'net/http'
require 'net/https'
require 'studio_api/studio_request_exception'
require 'studio_api/generic_request'

module SLMS
  module Studio
    class Packages
      def self.get_packageData (hsh={} )
        applianceId = hsh[:applianceId]
        image_type = (hsh[:image_type].nil? or hsh[:image_type] == "" ? nil : hsh[:image_type])

        data, success = GetRequest.request "/appliances/#{applianceId}/software/installed?#{(image_type ? 'image_type=' + image_type : '')}"
        raise StudioRequestException.new data unless success
        return XmlSimple.xml_in(data)
      end


      def self.download_rpm( output_stream, appliance_studio_id, name, options )
        request_str = "appliances/#{appliance_studio_id}/cmd/download_package?name=#{CGI.escape name}"
		Utils.append_options request_str, options

        data, success = SLMS::Studio::GetRequest.request request_str
        raise StudioRequestException.new("Failed to download rpm: '#{data.inspect}'") unless success

        output_stream.write(data)
	  end      

      def self.search(studio_appliance_id, package_name, options = {})
        request_str = "/appliances/#{studio_appliance_id}/software/search?q=#{package_name}"
        Utils.append_options request_str, options

        data, success = GetRequest.request request_str
        raise StudioRequestException.new("Failed to search package: '#{data.inspect}'") unless success

        return XmlSimple.xml_in(data)
      end

      def self.add_to_appliance studio_appliance_id, package_name, options={}
        req = "appliances/#{studio_appliance_id}/cmd/add_package?name=#{CGI.escape package_name}"
        Utils.append_options req, options
        data, success = PostRequest.new(req).go

        raise StudioRequestException.new("Failed to add package to appliance: '#{data.inspect}'") unless success
      end

      # deselect package in appliance.
      # If package is not in appliance it still success
      def self.remove_from_appliance studio_appliance_id, package_name
        req = "appliances/#{studio_appliance_id}/cmd/remove_package?name=#{CGI.escape package_name}"

        data, success = PostRequest.new(req).go

        raise StudioRequestException.new("Failed to remove package to appliance: '#{data.inspect}'") unless success
      end
    end


    class Builds
      def self.get_buildData (hsh={} )
        applianceId = hsh[:applianceId]

        data, success = GetRequest.request "/builds?appliance_id=#{applianceId}"
        raise StudioRequestException.new data unless success
        return XmlSimple.xml_in(data)
      end

      def self.build_expired?(hsh={} )
        appliance_id = hsh[:appliance_id]
        build_id     = hsh[:build_id]
        version      = hsh[:version]
        image_type   = hsh[:image_type]

        begin
          data = Builds.get_buildData(:applianceId => appliance_id ) 
          return false if data.nil?
  
          data["build"].each do |b|
            if ( b["id"].to_s == build_id.to_s ) || ( b["version"].to_s == version.to_s && b["image_type"] == image_type.to_s )
              return b["expired"][0].to_s == "true"
  	    end
          end
        rescue Exception => e
          return false
        end
        return false
      end
    end

    class RunningBuilds
      def self.get_buildData( params={} )
        raise "Parameter :applianceId must be defined" unless params[:applianceId]

        data, success = GetRequest.request "/running_builds?appliance_id=#{params[:applianceId]}"
        raise StudioRequestException.new data unless success
        return XmlSimple.xml_in(data)
      end

      def self.get_running_builds( params={} )
        unless params[:applianceId]
          raise "Parameter :applianceId must be defined"
        end

        begin
          data = get_buildData(:applianceId => params[:applianceId])
        rescue Exception => e
          logerror "Cannot get running builds for appliance/studio_id: #{params[:applianceId]}"
          logerror "Error: #{e.to_s}"
          return
        end

        if data.nil?
          logdebug "No running_builds data provided"
          return
        elsif data["running_build"].nil?
          logdebug "No builds are currently running for appliance/studio_id: #{params[:applianceId]}"
          return []
        end

        return data["running_build"].collect{
          |build|
          if build["id"] and build["id"].first
            build["id"].first
          else
            logerror "Broken data for running build #{build.inspect}"
          end
        }
      end
    end

    class Repositories
      def self.get_repositories_data(hsh={})
        applianceId = hsh[:applianceId]
        data, success = GetRequest.request "/appliances/#{applianceId}/repositories"
        raise StudioRequestException.new data unless success
        return XmlSimple.xml_in(data)
      end
    end
    
    class File < ActiveResource::Base
      #FIXME move to one module ARes setttings and method redefinition
      myconfig = SLMS::Config.get_config
      self.site = myconfig['SUSEStudio']['restapi']
      self.user = myconfig['SUSEStudio']['user']
      self.password = myconfig['SUSEStudio']['apikey']
      self.timeout = SLMS::Config.get_value('SUSEStudio', 'timeout', 45).to_i
      self.ssl_options = { :ca_path => SLMS::Config.get_value('SUSEStudio', 'sslcertpath', '/etc/ssl/certs'),
                           :verify_mode => OpenSSL::SSL::VERIFY_PEER }
      self.proxy = SLMS::Proxy::get_proxy_for(self.site)

      # We need to overwrite the paths methods because susestudio doesn't use the
      # standard .xml filename extension which is expected by ActiveResource.
      def self.element_path(id, prefix_options = {}, query_options = nil)
	prefix_options, query_options = split_options(prefix_options) if query_options.nil?
	"#{prefix(prefix_options)}#{collection_name}/#{id}#{query_string(query_options)}"
      end

      def self.collection_path(prefix_options = {}, query_options = nil)
	prefix_options, query_options = split_options(prefix_options) if query_options.nil?
	"#{prefix(prefix_options)}#{collection_name}#{query_string(query_options)}"
      end

      def self.download_file( studio_file_id, output_stream )
      data, success = GetRequest.request "/files/#{studio_file_id}/data"
      raise StudioRequestException.new("Failed to download file: '#{data.inspect}'") unless success

      output_stream.write(data)
      return true
      end

      def self.upload_file ( local_file_path, studio_appliance_id, options={} )
        request_str = "files?appliance_id=#{studio_appliance_id}"
        # add each option to request, so no need to change code if studio add additional option parameter
        Utils.append_options request_str, options

        begin 
          r = PostRequest.new request_str
          # reopen the file for request
          # ::File is needed to use "Ruby" file instead this one
          file = ::File.new( local_file_path, "r" )
          r.set_multipart_data :file =>file
          xml, success = r.go
        ensure
          file.close if file
        end

        raise StudioRequestException.new("Failed to upload file: '#{xml.inspect}'") unless success
        return true
      end
    end

    module Utils
      #append optional options to request string
      #WARN expect at least one mandatory option already appended
      def self.append_options request, options
        options.each do |k,v|
          request << "&#{CGI.escape k.to_s}=#{CGI.escape v}"
        end
      end
    end

    class APIVersion
      def self.get
        data, success = GetRequest.request "/api_version"
        raise StudioRequestException.new data unless success
        return XmlSimple.xml_in(data)
      end
  
      def self.is_compatible?
	# this function returns true if and only if SUSE Studio's API version is compatible
	
	begin
          # Note: take care when adapting the following line to new version numbers as it's a string comparison
          return SLMS::Studio::APIVersion.get >= "1.0"
        rescue Exception => e
          # we cannot access /api_version let's try /appliances to see whether the server responds (bnc #639718)
          data, success = GetRequest.request "/appliances" 
          raise StudioRequestException.new data unless success

          logwarn("Unable to detect SUSE Studio's API Version. This SUSE Studio Version might be unsupported.")
          return false
        end
      end
    end

  end # module Studio
end # module SLMS
