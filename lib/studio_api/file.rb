require "studio_api/resource"
require "cgi"
module StudioApi
  class File < Resource
    def download (output)
      rq = GenericRequest.new File.studio_connection
      data = rq.get "/files/#{id.to_i}/data"
      if output.respond_to? :write #already stream
        output.write data
      else #file name
        ::File.open(output.to_s,"w") do |f|
          f.write data
        end
      end
    end

    def self.upload ( input_path, appliance_id, options = {})
      request_str = "files?appliance_id=#{appliance_id.to_i}"
      options.each do |k,v|
        request_str << "&#{CGI.escape k.to_s}=#{CGI.escape v}"
      end
      
      rq = GenericRequest.new File.studio_connection
      rq.post request_str, input_path
    end
  end
end
