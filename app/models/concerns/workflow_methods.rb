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
    unless self.ready_to_publish?
      return

    wf = self.workflows.select{|wf| wf.identifier.first == wf_id}.first
    model = self.class.model_name.to_s
    status = "Migrate"
    msg = []

    unless self.datastreams.keys().include? "descMetadata"
      status = "System failure"
      msg << "No descMetadata available."
      #self.workflows.first.entries.build(description:msg.join(" "), creator:current_user, date:Time.now.to_s, status:status)
    end
    unless self.has_all_access_rights?
      status = "System failure"
      msg << "Not all files or the catalogue record has embargo details"
      #self.workflows.first.entries.build(description:msg.join(" "), creator:current_user, date:Time.now.to_s, status:status)
    end
    if status == "Migrate"
      open_access_content = self.list_open_access_content
      numberOfFiles = (open_access_content.select { |key| key.start_with?('content') }).length
      msg << "Open access datastreams: %s."%open_access_content.join(", ")

      if model == "Dataset"
        Resque.enqueue(DatabankPublishRecordJob, self.id.to_s, open_access_content, model, numberOfFiles.to_s)
      else
        # Add to ora publish queue
        args = {
          'pid' => self.id.to_s,
          'datastreams' => open_access_content,
          'model' => model,
          'numberOfFiles' => numberOfFiles.t_s
        }
        Resque.redis.rpush(Sufia.config.ora_publish_queue_name, args.to_json)
      end
    end

    self.workflows.first.entries.build(description: msg.join(" "), creator: current_user, date: Time.now.to_s, status: status)

  end

  def ready_to_publish?
    wf = self.workflows.select{|wf| wf.identifier.first == wf_id}.first
    model = self.class.model_name.to_s
    status = false
    unless Sufia.config.publish_to_queue_options.keys.include?(model.downcase)
      return status
    unless Sufia.config.publish_to_queue_options[model.downcase].include?(wf.current_status)
      return status
    occurences = wf.all_statuses.select{|s| s == wf.current_status}
    occurence = Sufia.config.publish_to_queue_options[model.downcase][wf.current_status]['occurence']
    return (occurences.length == occurence) || occurence == "all"
  end

end
