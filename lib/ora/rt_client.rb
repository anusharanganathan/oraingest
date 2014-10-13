require "rt/client"

module Ora
  class RtClient

    def initialize(queue=Sufia.config.rt_queue)
      @rt = RT_Client.new
      @queue = queue
    end
  
    def create(name, email, url, type)
      @cont = ApplicationController.new.render_to_string :partial => "/shared/emails/record_submitted", :locals => { :name => name, :url => url } 
      @ans = @rt.create(:Queue => @queue, :Subject => "Record submitted to ORA", :Requestor => email, :Cc => email, :Text => @cont)
      return @ans
    end

  end
end
