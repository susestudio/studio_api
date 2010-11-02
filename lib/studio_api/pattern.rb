module StudioApi
  class Pattern
    attr_accessor :name, :version, :repository_id, :arch
    def initialize name, attributes = {}
      @name = name
      attributes.each do |k,v|
        instance_variable_set "@#{k}", v
      end
    end
  end
end
