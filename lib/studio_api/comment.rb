module StudioApi
  # == Comment class
  # Represents comment attached to published appliance in gallery.
  #
  # Allows to read id, time, commenter name and text of comment together
  # with attached appliance
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

    # Post reply to comment with text
    # @param[String] text reply content
    def reply text
      appliance.post_comment text, :parent => id
    end
  end
end
