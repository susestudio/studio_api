module StudioApi
  # Represents package in appliance. Used mainly as data storage.
  class Package
    attr_accessor :name, :version, :repository_id, :arch, :checksum, :checksum_type
    def initialize name, attributes = {}
      @name = name
      attributes.each do |k,v|
        instance_variable_set "@#{k}", v
      end
    end
  end
end
