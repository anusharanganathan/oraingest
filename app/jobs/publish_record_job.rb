class PublishRecordJob 

  def queue_name
    :ora_publish
  end

  attr_accessor :pid, :datastreams, :model, :numberOfFiles

  def initialize(pid, datastreams, model, numberOfFiles)
    self.pid = pid
    self.datastreams = datastreams
    self.model = model
    self.numberOfFiles = numberOfFiles
  end

end

