require "studio_api/resource"
require "studio_api/generic_request"
require "studio_api/pattern"
require "studio_api/package"
require "xmlsimple"
require "fileutils"

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
      Status.find :one, :from => File.join(self.class.site.path, "appliances/#{id.to_i}/status")
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
      convert_selectable attrs
    end

    def installed_software (build_id = nil)
      request_str = "/appliances/#{id.to_i}/software/installed"
			request_str << "?build_id=#{build_id.to_i}" if build_id
      response = GenericRequest.new(self.class.studio_connection).get request_str
      attrs = XmlSimple.xml_in response
			res = []
			attrs["repository"].each do |repo|
				options = { "repository_id" => repo["id"].to_i }
      	res += convert_selectable repo["software"][0], options
			end
			res
    end

    def search_software (search_string,options={})
      request_str = "/appliances/#{id.to_i}/software/search?q=#{search_string}"
			options.each do |k,v|
				request_str << "&#{URI.escape k.to_s}=#{URI.escape v.to_s}"
			end
      response = GenericRequest.new(self.class.studio_connection).get request_str
      attrs = XmlSimple.xml_in response
			res = []
			attrs["repository"].each do |repo|
				options = { "repository_id" => repo["id"].to_i }
      	res += convert_selectable repo["software"][0], options
			end
			res
    end

		#options are version and repository_id
		def add_package (name, options={})
			appliance_command "add_package",{:name => name}.merge(options)
		end

		#options are version and repository_id
		def remove_package (name)
			appliance_command "remove_package",:name => name
		end

		#options are version and repository_id
		def add_pattern (name, options={})
			appliance_command "add_pattern",{:name => name}.merge(options)
		end

		#options are version and repository_id
		def remove_pattern (name)
			appliance_command "remove_pattern",:name => name
		end

		def ban_package(name)
			appliance_command "ban_package",:name => name
		end

		def unban_package(name)
			appliance_command "unban_package",:name => name
		end

private
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

    def convert_selectable attrs, preset_options = {}
      res = []
      (attrs["pattern"]||[]).each do |pattern|
        res << create_model_based_on_attrs(Pattern, pattern, preset_options)
      end
      (attrs["package"]||[]).each do |package|
        res << create_model_based_on_attrs( Package, package, preset_options)
      end
      res
    end

#generic factory to create model based on attrs which can be string of hash of options + content which is same as string
    def create_model_based_on_attrs model, attrs, preset_options
      case attrs
      when Hash
          name = attrs.delete "content"
          model.new(name, preset_options.merge(attrs))
      when String
          model.new(attrs)
      else
          raise "Unknown format of element #{model}"
      end
    end

		def appliance_command type, options={}
      request_str = "/appliances/#{id.to_i}/cmd/#{type}"
			unless options.empty?
				first = true
				options.each do |k,v|
					separator = first ? "?" : "&"
					first = false
					request_str << "#{separator}#{URI.escape k.to_s}=#{URI.escape v.to_s}"
				end
			end
      GenericRequest.new(self.class.studio_connection).post request_str, options
		end
  end
end
