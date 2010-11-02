require "studio_api/resource"
module StudioApi
  #method find :all has optional parameters base_system and filter
  class Repository < Resource
    undef_method :save #save is useless there

    def self.import (url, name)
      response = post '',:url => url, :name => name
      attrs = Hash.from_xml response.body
      Repository.new attrs["repository"]
    end

#handle special studio collection method for import
    def self.custom_method_collection_url(method_name, options = {})
      prefix_options, query_options = split_options(options)
      "#{prefix(prefix_options)}#{collection_name}#{query_string(query_options)}"
    end
  end
end
