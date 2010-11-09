require 'studio_api'
module StudioApi
  class Util
    def self.configure_studio_connection connection
      classes = get_all_usable_class StudioApi
      classes.each {|c| c.studio_connection = connection}
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
