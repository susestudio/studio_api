require "rubygems"
require 'active_resource'
require "studio_api/util"
require "studio_api/studio_resource"

module StudioApi
  # Adds ability to ActiveResource::Base (short as ARes) to easy set connection to studio in
  # dynamic way, which is not so easy as ARes is designed for static values.
  # Also modify a few expectation of ActiveResource to fit studio API ( like
  # missing xml suffix in calls ).
  #
  # @example Add new Studio Resource
  #   # enclose it in module allows to automatic settings with Util
  #   module StudioApi
  #     class NewCoolResource < ActiveResource::Base
  #       extend StudioResource
  #     end
  #   end

  module StudioResource

    # Gets studio connection. Mostly useful internally.
    # @return (StudioApi::Connection,nil) object of studio connection or nil if not
    # yet set
    def studio_connection
      @studio_connection
    end

    # hooks when module extend and ActiveResource based class
    # @param (ActiveResource::Base) extended class
    def self.extended(base)
      base.format = :xml #fix ARes 3.1 default ( json )
      # ensure that dasherize is not called as studio use in some keys '-'
      # need to extend it after inclusion
      base.class_eval do
        alias_method :original_encode, :encode
        def encode(options={})
          options[:dasherize] = false
          original_encode options
        end
      end
    end

    # Takes information from connection and sets it to ActiveResource::Base.
    # Also take care properly of prefix as it need to join path from site with
    # api prefix like appliance/:appliance_id .
    # @param (StudioApi::Connection) connection source for connection in
    #   activeResource
    # @return (StudioApi::Connection) unmodified parameter
    def studio_connection= connection
      self.site = connection.uri.to_s
      # there is general problem, that when specified prefix in model, it doesn't
      # contain uri.path as it is not know and uri is set during runtime, so we
      # must add here manually adapt prefix otherwise site.path is ommitted in
      # models which has own prefix in API
      unless @original_prefix
        if self.prefix_source == Util.join_relative_url(connection.uri.path,'/')
          @original_prefix = "/"
        else
          @original_prefix = self.prefix_source
        end
      end
      self.prefix = Util.join_relative_url connection.uri.path, @original_prefix
      self.user = connection.user
      self.password = connection.password
      self.timeout = connection.timeout
      self.proxy = connection.proxy.to_s if connection.proxy
      self.ssl_options = connection.ssl
      @studio_connection = connection
    end

    # We need to overwrite the paths methods because susestudio doesn't use the
    # standard .xml filename extension which is expected by ActiveResource.
    def element_path(id, prefix_options = {}, query_options = nil)
      inspect_connection
      prefix_options, query_options = split_options(prefix_options) if query_options.nil?
      "#{prefix(prefix_options)}#{collection_name}/#{id}#{query_string(query_options)}"
    end

    # We need to overwrite the paths methods because susestudio doesn't use the
    # standard .xml filename extension which is expected by ActiveResource.
    def collection_path(prefix_options = {}, query_options = nil)
      inspect_connection
      prefix_options, query_options = split_options(prefix_options) if query_options.nil?
      "#{prefix(prefix_options)}#{collection_name}#{query_string(query_options)}"
    end

    private

    def inspect_connection
      unless @studio_connection
        raise RuntimeError, 'Connection to Studio is not set
        Try: StudioApi::Util.studio_connection = StudioApi::Connection.new username, api_key, api_uri'
      end
    end
  end
end
