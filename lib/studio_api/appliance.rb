require "studio_api/resource"
require "studio_api/generic_request"
require "studio_api/pattern"
require "studio_api/package"
require "xmlsimple"
module StudioApi
  class Appliance < Resource
    class Status < Resource
    end

    class Repository < Resource
      self.prefix = "/appliances/:appliance_id/"
      self.element_name = "repository"
      mattr_accessor :appliance

      def delete
        self.class.appliance.remove_repository id
      end
    end
    
#there is need to manually define parsing of XML as ARes has problem with attributes in XML
    class Software < Resource
      self.prefix = "/appliances/:appliance_id/"
      self.collection_name = "software"
    end

    def status
      Status.set_connection self.class.studio_connection
      Status.find :one, :from => "/appliances/#{id.to_i}/status"
    end

    def repositories
      my_repo = Repository.dup
      my_repo.set_connection self.class.studio_connection
      my_repo.appliance = self
      my_repo.find :all, :params => { :appliance_id => id }
    end

    def remove_repository (*repo_ids)
      repo_ids.flatten.each do |repo_id|
        post "#{id}/cmd/remove_repository", :repo_id => repo_id
      end
    end

    def add_repository (*repo_ids)
      repo_ids.flatten.each do |repo_id|
        post "#{id}/cmd/add_repository", :repo_id => repo_id
      end
    end

    def add_user_repository
      post "#{id}/cmd/add_user_repository"
    end

    def clone options={}
      options[:appliance_id] = id
      post('',options)
    end

    def selected_software
      request_str = "/appliances/#{id.to_i}/software"
      response = GenericRequest.new(self.class.studio_connection).get request_str
      attrs = XmlSimple.xml_in response
      res = []
      attrs["pattern"].each do |pattern|
        res << Pattern.new(pattern)
      end
      attrs["package"].each do |package|
        res << case package
          when Hash
            Package.new(package["content"],package["version"])
          when String
            Package.new(package)
          else
            raise "Unknown format of element package"
          end
      end
      res
    end

#internal overwrite of ActiveResource::Base methods
    def new?
      false #Appliance has only POST method
    end

#studio post method for clone is special, as it sometime doesn't have element inside
    def custom_method_element_url(method_name,options = {})
      prefix_options, query_options = split_options(options)
      method_string = method_name.blank? ? "" : "/#{method_name}"
      "#{self.class.prefix(prefix_options)}#{self.class.collection_name}#{method_string}#{self.class.send :query_string,query_options}"
    end
  end
end
