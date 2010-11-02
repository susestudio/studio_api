require 'active_resource'

module StudioApi
  class Resource < ActiveResource::Base
    def self.studio_connection
      @studio_connection
    end

    def self.set_connection connection
      self.site = connection.uri.to_s
      self.user = connection.user
      self.password = connection.password
      self.timeout = connection.timeout
      self.proxy = connection.proxy.to_s if connection.proxy
#FIXME allow pass variable options
      self.ssl_options = {}
      self.ssl_options[:ca_path] = connection.ca_path if connection.ca_path
      self.ssl_options[:verify_mode] = connection.verify_mode if connection.verify_mode
      @studio_connection = connection
    end

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

  end
end
