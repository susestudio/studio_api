require 'studio_api'
module StudioApi
  # Utility class for handling whole stack of Studio Api
  class Util
    # Set connection for all StudioApi class, so then you can use it without explicit settings
    # It is useful when program use only one studio credentials
    # @example
    #   connection = StudioApi::Connection.new ( "user", "password", "http://localhost/api")
    #   StudioApi::Util.configure_studio_connection connection
    #   appliances = StudioApi::Appliance.find :all
    # @param [StudioApi::Connection] connection which is used for communication with studio
    # 
    def self.configure_studio_connection connection
      classes = get_all_usable_class StudioApi
      classes.each {|c| c.studio_connection = connection}
    end

    # joins relative url for unix servers as URI.join require at least one
    # absolut adress. Especially take care about only one slash otherwise studio
    # returns 404.
    # @param (Array<String>) args list of Strings to join
    # @return (String) joined String
    def self.join_relative_url(*args)
      args.reduce do |base, append|
        base= base[0..-2] if base.end_with? "/" #remove ending slash in base
        append = append[1..-1] if append.start_with? "/" #remove leading slash in append
        "#{base}/#{append}"
      end
    end
private
    def self.get_all_usable_class (modul)
      classes = modul.constants.collect{ |c| modul.const_get(c) }
      classes = classes.select { |c| c.class == Class && c.respond_to?(:studio_connection=) }
      inner_classes = classes.collect { |c| get_all_usable_class(c) }.flatten
      classes + inner_classes
    end
  end
end
