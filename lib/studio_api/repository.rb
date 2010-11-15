require "studio_api/studio_resource"
module StudioApi
  # Represents available repositories for appliance.
  #
  # Allows finding and importing repositories.
  # When using find :all then there is optional parameters for base_system and filter
  # 
  # @example Find repository with kde for SLE11
  #   StudioApi::Repository.find :all, :params => { :base_system => "sle11", :filter => "kde" }

  class Repository < ActiveResource::Base
    extend StudioResource

    undef_method :save #save is useless there
    undef_method :destroy #not allowed

    # Import new repository to Studio 
    #
    # note: Repository will be available to everyone
    # @param (#to_s) url to repository
    # @param (#to_s) name of created repository
    # @return [StudioApi::Repository] imported repository
    def self.import (url, name)
      response = post '',:url => url, :name => name
      attrs = Hash.from_xml response.body
      Repository.new attrs["repository"]
    end
private
#handle special studio collection method for import
    def self.custom_method_collection_url(method_name, options = {})
      prefix_options, query_options = split_options(options)
      "#{prefix(prefix_options)}#{collection_name}#{query_string(query_options)}"
    end
  end
end
