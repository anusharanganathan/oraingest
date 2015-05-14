class UpdatePublishRecordJob

  def queue_name
    :ora_publish_status
  end

  attr_accessor :pid, :datastreams, :model, :numberOfFiles, :status, :msg, :data, :dataOrig

  def initialize(data)
    self.dataOrig = data
    self.data = data
    self.data = self.data.gsub("=>", ":") #Stupid conversion that needs to be undone
    self.data = JSON.parse(self.data)
    self.pid = self.data["pid"]
    self.datastreams = self.data["datastreams"]
    self.model = self.data["model"]
    self.numberOfFiles = self.data["numberOfFiles"]
    self.status = self.data["status"]
    self.msg = self.data["msg"]
  end

  def run
    if self.model == "Article"
      obj = Article.find(self.pid)
    elsif self.model == "Dataset"
      obj = Dataset.find(self.pid)
    end
    wf = obj.workflows.first
    wf.entries.build
    wf.entries.last.status = "Published"
    wf.entries.last.creator = "ORA Deposit system"
    wf.entries.last.description = self.msg
    wf.entries.last.date = Time.now.to_s
    obj.save!
  end

  # Code to do when executing interactively
  #done = []
  #error = []
  #while $redis.llen("ora_publish_status") > 0
  #  begin
  #    dataOrig = $redis.lpop("ora_publish_status")
  #    data = dataOrig
  #    data = data.gsub("=>", ":") #Stupidly conversion that needs to be undone
  #    data = JSON.parse(data)
  #    if data["model"] == "Article"
  #      obj = Article.find(data["pid"])
  #    elsif data["model"] == "Dataset"
  #      obj = Dataset.find(data["pid"])
  #    end
  #    wf = obj.workflows.first
  #    wf.entries.build
  #    wf.entries.last.status = "Published"
  #    wf.entries.last.creator = "ORA Deposit system"
  #    wf.entries.last.description = data["msg"]
  #    wf.entries.last.date = Time.now.to_s
  #    obj.save!
  #    done << data["pid"]
  #  rescue
  #    error << dataOrig
  #  end
  #end

end
