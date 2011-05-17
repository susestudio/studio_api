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

require 'uri'
require 'openssl'
require 'studio_api/generic_request'

module StudioApi
  # Represents information needed for connection to studio.
  # In common case it is just needed once initialize and then pass it to classes.
  class Connection
    # SSL attributes which can be set into ssl attributes. For more details see openssl library
    SSL_ATTRIBUTES = [ :key, :cert, :ca_file, :ca_path, :verify_mode, :verify_callback, :verify_depth, :cert_store ]
    # Represents login name for studio API
    attr_reader :user
    # Represents API key for studio API
    attr_reader :password
    # Represents URI pointing to studio site including path to API
    # @example
    #   connection.uri == URI.parse "http://susestudio.com/api/v1/user/"
    attr_reader :uri
    # Represents proxy object needed for connection to studio API.
    # nil represents that no proxy needed
    attr_reader :proxy
    # Represents timeout for connection in seconds.
    attr_reader :timeout
    # Represents settings for SSL verification in case of uri is https.
    # It is Hash with keys from SSL_ATTRIBUTES
    attr_reader :ssl

    # Creates new object
    # @example
    #   StudioApi::Connection.new "user","pwd","https://susestudio.com//api/v1/user/",
    #                             :timeout => 120, :proxy => "http://user:pwd@proxy",
    #                             :ssl => { :verify_mode => OpenSSL::SSL::VERIFY_PEER,
    #                                       :ca_path => "/etc/studio.cert"}
    # @param [String] user login to studio API
    # @param (String) password API key for studio
    # @param (String,URI) uri pointing to studio site including path to api
    # @param (Hash) options hash of additional options. Represents other attributes.
    # @option options [URI,String] :proxy (nil) see proxy attribute
    # @option options [String, Fixnum] :timeout (45) see timeout attribute. Specified in seconds
    # @option options [Hash] :ssl ( {:verify_mode = OpenSSL::SSL::VERIFY_NONE}) see ssl attribute
    #   
    def initialize(user, password, uri, options={})
      @user = user
      @password = password
      self.uri = uri
      self.proxy = options[:proxy] #nil as default is OK
      @timeout = (options[:timeout] || 45).to_i
      @ssl = options[:ssl] || { :verify_mode => OpenSSL::SSL::VERIFY_NONE } # don't verify as default
    end

    def api_version
      @version ||= version_detect
    end
protected
    
    # Overwritte uri object.
    # @param (String,URI) value new uri to site. If String is passed then it is parsed by URI.parse, which can throw exception
    def uri=(value)
      if value.is_a? String
        @uri = URI.parse value
      else
        @uri = value
      end
    end

    # Overwritte proxy object.
    # @param (String,URI,nil) value new proxy to site. If String is passed then it is parsed by URI.parse, which can throw exception. If nil is passed then it means disable proxy.
    def proxy=(value)
      if value.is_a? String
        @proxy = URI.parse value
      else
        @proxy = value
      end
    end

private
    def version_detect
      rq = GenericRequest.new self
      response = rq.get "/api_version"
      Hash.from_xml(response)["version"]
    end
  end
end
