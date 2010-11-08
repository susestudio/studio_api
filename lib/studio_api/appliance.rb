require "studio_api/resource"
require "studio_api/generic_request"
require "studio_api/pattern"
require "studio_api/package"
require "xmlsimple"
require "fileutils"

module StudioApi
  class Appliance < Resource
    self.element_name = "appliance"

    class Status < Resource
    end

    class Repository < Resource
      self.prefix = "/appliances/:appliance_id/"
      self.element_name = "repository"
      mattr_accessor :appliance

      #for delete repository doesn't work clasic method from ARes
      def destroy
        self.class.appliance.remove_repository id
      end

      #for delete repository doesn't work clasic method from ARes
      def self.delete (id, options)
        my_app = Appliance.dup
        my_app.studio_connection = studio_connection
        my_app.new(:id => options[:appliance_id]).remove_repository id
      end
    end
    
    class GpgKey < Resource
      self.prefix = "/appliances/:appliance_id/"
      self.element_name = "gpg_key"
      mattr_accessor :appliance

      def self.create (appliance_id, name, key, options={})
        options[:target] ||= "rpm"
        if key.is_a? String #if key is string, that pass it in request, if not pack it in body
          options[:key] = key
        end
        request_str = "/appliances/#{appliance_id.to_i}/gpg_keys?name=#{name}"
        options.each do |k,v|
          request_str << "&#{URI.escape k.to_s}=#{URI.escape v.to_s}"
        end
        GenericRequest.new(studio_connection).post request_str, :key => key
      end
    end

    def status
      Status.studio_connection = self.class.studio_connection
      #rails is so smart, that it ignores prefix for calls. At least it is good that we don't want to do such things from library users
      from = self.class.join_relative_url( self.class.site.path,"appliances/#{id.to_i}/status")
      Status.find :one, :from => from
    end

    def repositories
      my_repo = Repository.dup
      my_repo.studio_connection = self.class.studio_connection
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

    def gpg_keys
      my_key = GpgKey.dup
      my_key.studio_connection = self.class.studio_connection
      my_key.find :all, :params => { :appliance_id => id }
    end

    def gpg_key( key_id )
      my_key = GpgKey.dup
      my_key.studio_connection = self.class.studio_connection
      my_key.find key_id, :params => { :appliance_id => id }
    end

    def add_gpg_key (name, key, options={})
      my_key = GpgKey.dup
      my_key.studio_connection = self.class.studio_connection
      my_key.create id, name, key, options
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
