class UpdatePublishRecordJob

  def queue_name
    :ora_publish_status
  end

  attr_accessor :pid, :datastreams, :model, :numberOfFiles, :status, :msg

  def initialize(pid, datastreams, model, numberOfFiles, status, msg)
    self.pid = pid
    self.datastreams = datastreams
    self.model = model
    self.numberOfFiles = numberOfFiles
    self.status = status
    self.msg = msg
  end

  def self.perform()
    if self.model == "Article"
      obj = Article.find(self.pid)
    elsif self.model == "Dataset"
      obj = Dataset.find(self.pid)
    end
    wf = obj.workflows.first
    wf.entries.build
    wf.entries.last.status = "Published"
    wf.entries.last.reviewer_id = "ORA Deposit system"
    wf.entries.last.description = self.msg
    wf.entries.last.date = Time.now.to_s
    obj.save!
  end

end
