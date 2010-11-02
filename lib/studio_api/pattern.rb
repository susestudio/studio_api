module StudioApi
  class Pattern
    attr_accessor :name, :version
    def initialize name, version = nil
      @name = name
      @version = version
    end
  end
end
