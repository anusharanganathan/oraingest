class updatePublishRecordJob

  def queue_name
    :ora_publish_status
  end

  attr_accessor :pid, :datastreams, :model, :numberOfFiles

  def initialize(pid, datastreams, model, numberOfFiles)
    self.pid = pid
    self.datastreams = datastreams
    self.model = model
    self.numberOfFiles = numberOfFiles
  end

  def self.perform()
    #wf = article.workflows.first
    #wf.entries.build
    #wf.entries.last.status = From redis queue - one of Sufia.config.workflow_status
    #wf.entries.last.reviewer_id = "ORA Deposit system"
    #wf.entries.last.description = From redis queue   
  end

end
