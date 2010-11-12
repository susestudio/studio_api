require "studio_api/studio_resource"

module StudioApi
  # Represents created build in studio. It allows finding and deleting.
  # 
  # @example Delete version 0.0.1 (all types)
  #   builds = Build.find(:all,:params=>{:appliance_id => 1234})
  #   versions1 = builds.select { |b| b.version == "0.0.1" }
  #   versions1.each {|v| v.destroy }

  class Build < ActiveResource::Base
    extend StudioResource

    self.element_name = "build"
    undef_method :save
  end
end
