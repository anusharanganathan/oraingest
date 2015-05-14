class UpdatePublishRecordJob

  @queue = :ora_publish_status

  def self.perform(data)
    data = JSON.parse(data)
    if data["model"] == "Article"
      obj = Article.find(data["pid"])
    elsif data["model"] == "Dataset"
      obj = Dataset.find(data["pid"])
    end
    wf = obj.workflows.first
    wf.entries.build
    wf.entries.last.status = "Published"
    wf.entries.last.creator = "ORA Deposit system"
    wf.entries.last.description = data["msg"]
    wf.entries.last.date = Time.now.to_s
    obj.save!
  end

end
