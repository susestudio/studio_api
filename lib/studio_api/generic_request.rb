#
#  Copyright (c) 2010 Novell, Inc.
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
require 'cgi'
require 'net/http'
require 'net/https'
require 'active_support'
require 'active_resource/formats'
require 'active_resource/connection'
require 'tempfile' unless defined? Tempfile
require 'securerandom'

require 'studio_api/util'

module StudioApi
  # Class which use itself direct connection to studio for tasks where
  # ActiveResource is not enough. For consistent api is all network exceptions
  # mapped to ones used in ActiveResource.
  #
  # @example
  #   rq = StudioApi::GenericRequest.new @connection
  #   rq.get "/appliances"
  #   rq.post "/file", :file => "/etc/config"
  class GenericRequest
    # Creates new instance of request for given connection
    # @param (StudioApi::Connection) connection information about connection
    def initialize(connection)
      @connection = connection
      if connection.proxy
        proxy = connection.proxy
        @http = Net::HTTP.new(connection.uri.host, connection.uri.port,
            proxy.host, proxy.port, proxy.user, proxy.password)
      else
        @http = Net::HTTP.new(connection.uri.host, connection.uri.port)
      end
      @http.read_timeout = connection.timeout
      if connection.uri.scheme == "https"
        @http.use_ssl = true
        Connection::SSL_ATTRIBUTES.each do |attr|
          @http.send :"#{attr}=", connection.ssl[attr.to_sym] if connection.ssl[attr.to_sym]
        end
      end
    end

    # sends get request
    # @param (String) path relative path from api root
    # @return (String) response body from studio
    # @raise [ActiveResource::ConnectionError] when problem occur during connection
    def get(path)
      do_request(Net::HTTP::Get.new(Util.join_relative_url(@connection.uri.request_uri,path)))
    end

    # sends get request to suse studio
    # @return (nil) as response
    # @raise [ActiveResource::ConnectionError] when problem occur during connection
    def get_file(path, &block)
      do_tempfile_request(Net::HTTP::Get.new(
        Util.join_relative_url(@connection.uri.request_uri,path)),
        &block)
    end

    # sends delete request
    # @param (String) path relative path from api root
    # @return (String) response body from studio
    # @raise [ActiveResource::ConnectionError] when problem occur during connection
    def delete(path)
      #Even it is not dry I want to avoid meta programming with dynamic code evaluation so code is clear
      do_request(Net::HTTP::Delete.new(Util.join_relative_url(@connection.uri.request_uri,path)))
    end

    # sends post request
    # @param (String) path relative path from api root
    # @param (Hash<#to_s,#to_s>,Hash<#to_s,#path>) data hash containing data to attach to body
    # @return (String) response body from studio
    # @raise [ActiveResource::ConnectionError] when problem occur during connection
    def post(path,data={})
      request = Net::HTTP::Post.new(Util.join_relative_url(@connection.uri.request_uri,path))
      set_data(request,data) unless data.empty?
      do_request request
    end

    # sends post request
    # @param (String) path relative path from api root
    # @param (Hash<#to_s,#to_s>,Hash<#to_s,#path>) data hash containing data to attach to body
    # @return (String) response body from studio
    # @raise [ActiveResource::ConnectionError] when problem occur during connection
    def put(path,data={})
      request = Net::HTTP::Put.new(Util.join_relative_url(@connection.uri.request_uri,path))
      set_data(request,data) unless data.empty?
      do_request request
    end

  private
    def do_request(request)
      request.basic_auth @connection.user, @connection.password
      @http.start() do
        response = @http.request request
        handle_active_resource_exception response
        response.body
      end
    end

    def do_tempfile_request request, &block
      request.basic_auth @connection.user, @connection.password
      @http.start do |http|
        Tempfile.open SecureRandom.hex(10) do |tmp|
          http.request request do |response|
            handle_active_resource_exception response
            response.read_body {|body| tmp.write body }
          end
          yield tmp
        end
      end
    end

      #XXX not so nice to use internal method, but better to be DRY and proper test if it works with supported rails
    def handle_active_resource_exception response
      unless response.kind_of? Net::HTTPSuccess
        msg = error_message response
        response.instance_variable_set "@message",msg
        ActiveResource::Connection.new('').send :handle_response, response
      end
    end

    def error_message response
      xml_parsed = XmlSimple.xml_in(response.body, {'KeepRoot' => true})
      raise "Unknown error response from Studio: #{response.body}" unless xml_parsed['error']
      msg = ""
      xml_parsed['error'].each() {|error| msg << error['message'][0]+"\n" }
      return msg
    rescue RuntimeError
      return response.message+"\n"+response.body
    end

    def set_data(request,data)
      if data[:__raw]
        request.body = data[:__raw]
      else
        boundary = Time.now.to_i.to_s(16)
        request["Content-Type"] = "multipart/form-data; boundary=#{boundary}"
        body = ""
        data.each do |key,value|
          esc_key = CGI.escape(key.to_s)
          body << "--#{boundary}\r\n"
          if value.respond_to?(:read) && value.respond_to?(:path)
            # ::File is needed to use "Ruby" file instead this one
            body << "Content-Disposition: form-data; name=\"#{esc_key}\"; filename=\"#{::File.basename(value.path)}\"\r\n"
            body << "Content-Type: #{mime_type(value.path)}\r\n\r\n"
            body << value.read
          else
            body << "Content-Disposition: form-data; name=\"#{esc_key}\"\r\n\r\n#{value}"
          end
          body << "\r\n"
        end
        body << "--#{boundary}--\r\n\r\n"
        request.body = body
        request["Content-Length"] = request.body.size
      end
    end

    def mime_type(file)
      case
        when file =~ /\.jpe?g\z/i then 'image/jpg'
        when file =~ /\.gif\z/i then 'image/gif'
        when file =~ /\.png\z/i then 'image/png'
        else 'application/octet-stream'
      end
    end
  end
end
