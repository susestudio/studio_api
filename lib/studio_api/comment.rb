module StudioApi
  class Comment
    attr_reader :id, :timestamp, :username, :text, :appliance

    def initialize hash
      hash.each do |k,v|
        instance_variable_set :"@#{k}", v
      end
    end

    def self.parse(appliance, hash)
      Comment.new hash.merge(:appliance => appliance)
    end

    def reply text
      appliance.post_comment text, :parent => id
    end
  end
end
