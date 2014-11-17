require "rt/client"

module Ora
  class RtClient

    def initialize(queue=Sufia.config.rt_queue)
      @rt = RT_Client.new
      @queue = queue
    end
  
    def email_content(template, data, user)
      @cont = ApplicationController.new.render_to_string :partial => template, :locals => { :data => data, :user => user } rescue nil
      return @cont
    end

    def create_ticket(subject, email_address, content)
      @ans = @rt.create(:Queue => @queue, :Subject => subject, :Requestor => email_address, :Cc => email_address, :Text => content)
      return @ans
    end

  end
end
