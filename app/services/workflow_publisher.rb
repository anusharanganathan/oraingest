class WorkflowPublisher

  attr_accessor :parent_model
  
  def initialize(model)
    @parent_model
  end

  def perform_action(current_user)
    model_klass = parent_model.class.model_name.to_s
    # send email
    models = { "Article" => 'articles', "DatasetAgreement" => "dataset_agreements", "Dataset" => "datasets" }
    record_url = Rails.application.routes.url_helpers.url_for(:controller => models[model_klass], :action=>'show', :id => parent_model.id)
    data = {"record_id" => parent_model.id, "record_url" => record_url, "doi_requested"=>parent_model.doi_requested}
    if parent_model.doi_requested
      data["doi"] = parent_model.doi(mint=false)
    end
    ans = parent_model.datastreams["workflowMetadata"].send_email("MediatedSubmission", data, current_user, model_klass)
    # publish record
    publishRecord("MediatedSubmission", current_user)
  end

  def publishRecord(wf_id, current_user)
    # Send pid and list of open datastreams to queue
    # If datastreams are empty, that means record is all dark
    wf = parent_model.workflows.select{|wf| wf.identifier.first == wf_id}.first
    model_klass = parent_model.class.model_name.to_s
    #Use Sufia.config.publish_to_queue_options to determine if method needs to be called
    if wf && Sufia.config.publish_to_queue_options.keys.include?(model_klass.downcase) && Sufia.config.publish_to_queue_options[model_klass.downcase].include?(wf.current_status)
      # The status is available for this model in the config
      occurences = wf.all_statuses.select{|s| s == wf.current_status}
      occurence = Sufia.config.publish_to_queue_options[model_klass.downcase][wf.current_status]['occurence']
      if (occurences.length == occurence) || occurence == "all"
        # The occurence count matches and so procedd to performing action
        toMigrate = false
        msg = []
        datastreams = []
        numberOfFiles = 0
        #Get list of all datastreams without access rights
        conts = parent_model.datastreams.keys.select { |key| key.start_with?('content') and parent_model.datastreams[key].content != nil }
        parent_model.hasPart.each do |hp|
          if conts.include?(hp.identifier[0])
            numberOfFiles = numberOfFiles + 1
            if !hp.accessRights.nil? && !hp.accessRights[0].embargoStatus.nil? && !hp.accessRights[0].embargoStatus[0].nil? && !hp.accessRights[0].embargoStatus[0].empty?
              conts.delete(hp.identifier[0])
            end
          end
        end
        # If access rights not defined for file or catalogue record, mark as system failure
        if !conts.empty? || parent_model.accessRights.nil? || parent_model.accessRights[0].embargoStatus.nil?
          status = "System failure"
          if parent_model.accessRights.nil? || parent_model.accessRights[0].embargoStatus.nil?
            msg << "No embargo details for catalogue record."
          end
          if !conts.empty?
            conts.each do |ds|
              msg << "No embargo details for #{ds}."
            end
          end
          # If catalogue record is open access, gather datastreams to migrate
        elsif parent_model.accessRights[0].embargoStatus[0] == "Open access"
          if parent_model.datastreams.keys().include? "descMetadata"
            status = "Migrate"
            toMigrate = true
            datastreams << "descMetadata"
            if parent_model.datastreams.keys().include? "relationsMetadata"
              datastreams << "relationsMetadata"
            end
            parent_model.hasPart.each do |hp|
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
        elsif parent_model.accessRights[0].embargoStatus[0] != "Open access"
          toMigrate = true
          status = "Migrate" #Set to Migrate, depending on archive policy
          msg << "Catalogue record is #{parent_model.accessRights[0].embargoStatus[0]}."
        end
        # Update status of object
        parent_model.workflows.first.entries.build(description:msg.join(" "), creator:current_user, date:Time.now.to_s, status:status)
        # Push object to queue
        if toMigrate
          if model_klass == "Dataset"
            Resque.enqueue(DatabankPublishRecordJob, parent_model.id.to_s, datastreams, model_klass, numberOfFiles.to_s)
          else
            # Add to ora publish queue
            args = {
                'pid' => parent_model.id.to_s,
                'datastreams' => datastreams,
                'model' => model_klass,
                'numberOfFiles' => numberOfFiles.t_s
            }
            Resque.redis.rpush(Sufia.config.ora_publish_queue_name, args.to_json)
          end
        end
        #else
        #  # Note: Not doing this as we may just add a whole lot of comments for redundant clicks
        #  # Cannot publish as not not the correct occurence. Add comment and return
        #  msg = "Record cannot be processed for count of current status is #{occurence.to_s}."
        #  comment = {:description => msg, :creator => current_user, :date => Time.now.to_s}
        #  parent_model.workflows.first.comments.build(comment)
      end
      #else
      #  # Note: Not doing this as we may just add a whole lot of comments for redundant clicks
      #  # Cannot publish as not approved. Add comment and return
      #  msg = "Record cannot be processed for current status #{parent_model.workflows.first.current_status}."
      #  comment = {:description => msg, :creator => current_user, :date => Time.now.to_s}
      #  parent_model.workflows.first.comments.build(comment)
    end
  end
end