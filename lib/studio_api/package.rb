module StudioApi
  class Package
    attr_accessor :name, :version, :repository
    def initialize name, version = nil, repository = nil
      @name = name
      @version = version
      @repository = repository
    end
  end
end
