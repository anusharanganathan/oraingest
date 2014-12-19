class PublishRecordJob 

  def queue_name
    :ora_publish
  end

  attr_accessor :pid, :datastreams

  def initialize(pid, datastreams, model)
    self.pid = pid
    self.datastreams = datastreams
    self.model = model
  end

end

