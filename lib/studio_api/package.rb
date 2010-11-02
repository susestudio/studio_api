module StudioApi
  class Package
    attr_accessor :name, :version, :repository_id, :Arch, :checksum, :checksum_type
    def initialize name, attributes = {}
      @name = name
      attributes.each do |k,v|
        instance_variable_set "@#{k}", v
      end
    end
  end
end
