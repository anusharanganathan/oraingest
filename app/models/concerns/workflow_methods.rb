require 'ora/resque'

module WorkflowMethods
  extend ActiveSupport::Concern

  def perform_action(current_user)
    model = self.class.model_name.to_s
    # send email
    models = { "Article" => 'articles', "DatasetAgreement" => "dataset_agreements", "Dataset" => "datasets" }
    record_url = Rails.application.routes.url_helpers.url_for(:controller => models[model], :action=>'show', :id => self.id)
    data = {"record_id" => self.id, "record_url" => record_url, "doi_requested"=>self.doi_requested}
    if self.doi_requested
      data["doi"] = self.doi(mint=false)
    end
    ans = self.datastreams["workflowMetadata"].send_email("MediatedSubmission", data, current_user, model)
    # publish record
    publishRecord("MediatedSubmission", current_user)
  end

  def publishRecord(wf_id, current_user)
    # Send pid and list of open datastreams to queue
    # If datastreams are empty, that means record is all dark
    wf = self.workflows.select{|wf| wf.identifier.first == wf_id}.first
    model = self.class.model_name.to_s
    #Use Sufia.config.publish_to_queue_options to determine if method needs to be called
    if wf && Sufia.config.publish_to_queue_options.keys.include?(model.downcase) && Sufia.config.publish_to_queue_options[model.downcase].include?(wf.current_status)
      # The status is available for this model in the config
      occurences = wf.all_statuses.select{|s| s == wf.current_status}
      occurence = Sufia.config.publish_to_queue_options[model.downcase][wf.current_status]['occurence']
      if (occurences.length == occurence) || occurence == "all"
        # The occurence count matches and so procedd to performing action
        toMigrate = false
        msg = []
        datastreams = []
        numberOfFiles = 0
        #Get list of all datastreams without access rights
        conts = self.datastreams.keys.select { |key| key.start_with?('content') and self.datastreams[key].content != nil }
        self.hasPart.each do |hp|
          if conts.include?(hp.identifier[0])
            numberOfFiles = numberOfFiles + 1
            if !hp.accessRights.nil? && !hp.accessRights[0].embargoStatus.nil? && !hp.accessRights[0].embargoStatus[0].nil? && !hp.accessRights[0].embargoStatus[0].empty?
              conts.delete(hp.identifier[0])
            end
          end
        end
        # If access rights not defined for file or catalogue record, mark as system failure
        if !conts.empty? || self.accessRights.nil? || self.accessRights[0].embargoStatus.nil?
          status = "System failure"
          if self.accessRights.nil? || self.accessRights[0].embargoStatus.nil?
            msg << "No embargo details for catalogue record."
          end
          if !conts.empty?
            conts.each do |ds|
              msg << "No embargo details for #{ds}."
            end
          end
        # If catalogue record is open access, gather datastreams to migrate
        elsif self.accessRights[0].embargoStatus[0] == "Open access"
          if self.datastreams.keys().include? "descMetadata"
            status = "Migrate"
            toMigrate = true
            datastreams << "descMetadata"
            if self.datastreams.keys().include? "relationsMetadata"
              datastreams << "relationsMetadata"
            end
            self.hasPart.each do |hp|
              if hp.accessRights[0].embargoStatus[0] == "Open access"
                datastreams << "#{hp.identifier[0]}"
              end
            end
            msg << "Datastreams to migrate: %s."%datastreams.join(", ")
          else
            msg << "No descMetadata available."
            status = "System failure"
          end
        # If catalogue record is not open access, no datastreams to gather
        elsif self.accessRights[0].embargoStatus[0] != "Open access"
          toMigrate = true
          status = "Migrate" #Set to Migrate, depending on archive policy
          msg << "Catalogue record is #{self.accessRights[0].embargoStatus[0]}."
        end
        # Update status of object
        self.workflows.first.entries.build(description:msg.join(" "), creator:current_user, date:Time.now.to_s, status:status)
        # Push object to queue
        if toMigrate
          Sufia.queue.push_raw(PublishRecordJob.new(self.id.to_s, datastreams, self.class.model_name.to_s, numberOfFiles.to_s))
        end
      #else
      #  # Note: Not doing this as we may just add a whole lot of comments for redundant clicks
      #  # Cannot publish as not not the correct occurence. Add comment and return
      #  msg = "Record cannot be processed for count of current status is #{occurence.to_s}."
      #  comment = {:description => msg, :creator => current_user, :date => Time.now.to_s}
      #  self.workflows.first.comments.build(comment)
      end
    #else
    #  # Note: Not doing this as we may just add a whole lot of comments for redundant clicks
    #  # Cannot publish as not approved. Add comment and return
    #  msg = "Record cannot be processed for current status #{self.workflows.first.current_status}."
    #  comment = {:description => msg, :creator => current_user, :date => Time.now.to_s}
    #  self.workflows.first.comments.build(comment)
    end
  end

end
