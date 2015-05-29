class WorkflowPublisher

  attr_accessor :parent_model
  
  def initialize(model)
    @parent_model
  end
  
  def perform_action(current_user)
    # send email
    models = { "Article" => 'articles', "DatasetAgreement" => "dataset_agreements", "Dataset" => "datasets" }
    record_url = Rails.application.routes.url_helpers.url_for(:controller => models[parent_model.model_klass], :action=>'show', :id => parent_model.id)
    data = {"record_id" => parent_model.id, "record_url" => record_url, "doi_requested"=>parent_model.doi_requested?}
    if parent_model.doi_requested?
      data["doi"] = parent_model.doi(mint=false)
    end
    ans = parent_model.datastreams["workflowMetadata"].send_email("MediatedSubmission", data, current_user, parent_model.model_klass)
    # publish record
    publish_record("MediatedSubmission", current_user)
  end

  def publish_record(wf_id, current_user)
    # Send pid and list of open datastreams to queue
    # If datastreams are empty, that means record is all dark
    unless ready_to_publish?(wf_id=wf_id)
      return
    end
    ans, msg = check_minimum_metadata
    unless ans
      status = "System failure"
    else
      status = "System verified"
      open_access_content = parent_model.list_open_access_content
      numberOfFiles = (open_access_content.select { |key| key.start_with?('content') }).length
      msg << "Open access datastreams: %s."%open_access_content.join(", ")
      if parent_model.model_klass == "Dataset"
        Resque.enqueue(DatabankPublishRecordJob, parent_model.id.to_s, open_access_content, parent_model.model_klass, numberOfFiles.to_s)
      else
        # Add to ora publish queue
        args = {
            'pid' => parent_model.id.to_s,
            'datastreams' => open_access_content,
            'model' => parent_model.model_klass,
            'numberOfFiles' => numberOfFiles.to_s
        }
        Resque.redis.rpush(Sufia.config.ora_publish_queue_name, args.to_json)
      end
    end
    update_status(status, msg)
  end

  def ready_to_publish?(wf_id="MediatedSubmission")
    wf = parent_model.workflows.select{|wf| wf.identifier.first == wf_id}.first
    status = false
    if wf.nil?
      return status
    end
    unless Sufia.config.publish_to_queue_options.keys.include?(parent_model.model_klass.downcase)
      return status
    end
    unless Sufia.config.publish_to_queue_options[parent_model.model_klass.downcase].include?(wf.current_status)
      return status
    end
    occurences = wf.all_statuses.select{|s| s == wf.current_status}
    occurence = Sufia.config.publish_to_queue_options[parent_model.model_klass.downcase][wf.current_status]['occurence']
    return (occurences.length == occurence) || occurence == "all"
  end

  def check_minimum_metadata
    status = true
    msg = []
    # descMetadata has to exist
    unless parent_model.datastreams.keys().include? 'descMetadata'
      status = false
      msg << 'No descMetadata available.'
    end
    # All of the access rights should be in place
    unless parent_model.has_all_access_rights?
      status = false
      msg << 'Not all files or the catalogue record has embargo details'
    end
    # The metadata for regsitering DOI should exist
    if parent_model.model_klass == 'Dataset' && parent_model.doi_requested?
      unless parent_model.doi_registered?
        payload = parent_model.doi_data
        dd = ORA::DataDoi.new(Sufia.config.doi_credentials)
        # validate required fields
        begin
          dd.validate_required(payload)
        rescue ORA::DataValidationError => e
          status = false
          msg << e.message
        end
        # validate xml to schema
        begin
          dd.validate_xml(payload)
        rescue ORA::DataValidationError => e
          status = false
          msg << e.message
        end
      end
    end
    return status, msg
  end

  def update_status(status, description, creator='ORA Deposit system', wf_id="MediatedSubmission")
    #Update the workflow status. Add a new workflow entry.
    unless Sufia.config.workflow_status.include?(status)
      return false
    end
    wf = parent_model.workflows.select{|wf| wf.identifier.first == wf_id}.first
    wf.entries.build
    wf.entries.last.status = Sufia.config.workflow_status[status]
    wf.entries.last.creator = creator
    if description.is_a?(Array)
      description = description.join('\n')
    end
    wf.entries.last.description = description
    wf.entries.last.date = Time.now.to_s
    return true
  end

end
