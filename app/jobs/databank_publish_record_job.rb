require 'ora/databank'

class DatabankPublishRecordJob

  @queue = :databank_publish

  def self.perform(pid, datastreams, model, numberOfFiles)
    if model == "Article"
      return
    end
    m = MigrateData.new(pid, datastreams, model, numberOfFiles)
    m.create_dataset()
    m.upload_to_databank()
    m.update_status()
    if m.status
      m.update_content_datastreams()
      m.add_to_next_queue()
    end
    m.save()
  end

end

class MigrateData

  attr_accessor :pid, :datastreams, :model, :numberOfFiles, :dataset, :status, :msg, :silo, :content_files

  def initialize(pid, datastreams, model, numberOfFiles)
    self.pid = pid
    self.datastreams = datastreams
    self.model = model
    self.numberOfFiles = numberOfFiles
    self.dataset = pid.sub('uuid:', '')
    self.status = true
    self.msg = []
    self.content_files = {}
    dc = Sufia.config.databank_credentials
    self.silo = dc['silo']
    @obj = Dataset.find(self.pid)
    @databank = Databank.new(dc['host'], username=dc['username'], password=dc['password'])
  end

  def create_dataset()
    #create dataset if it doesn't exist
    ans = @databank.getDataset(self.silo, self.dataset)
    if !@databank.responseGood(ans['code'])
      ans = @databank.createDataset(self.silo, self.dataset, label=nil, embargoed="true")
      if @databank.responseGood(ans['code'])
        self.msg << "Created Dataset #{self.dataset}"
      else
        self.msg << "Error creating Dataset #{self.dataset}"
        self.status = false
      end
    else
      self.msg << "Dataset #{self.dataset} exists"
    end
  end
  
  def upload_to_databank()
    if self.status
      @obj.datastreams.keys.each do |ds|
        next if ds == 'DC'
        if ds.start_with?('content')
          filepath = upload_content(ds)
          self.content_files[ds] = filepath
        else
          upload_metadata(ds)
        end
      end
    end
  end

  def upload_content(ds)
    # Get file path and file name
    opts = @obj.datastream_opts(ds)
    filepath = opts["dsLocation"]
    filename = File.basename filepath
    ans = @databank.uploadFile(self.silo, self.dataset, filepath, filename=filename)
    if @databank.responseGood(ans['code'])
      self.msg << "Uploaded file #{ds}"
    else
      self.msg << "Error uploading file #{ds}"
      self.status = false
    end
    return filepath
  end

  def upload_metadata(ds)
    case ds
    when "RELS-EXT"
      ext = '.rdf'
    when "rightsMetadata"
      ext = '.xml'
    else
      ext = ".ttl"
    end
    cont = @obj.datastreams[ds].content
    file = Tempfile.new([ ds, ext ], Sufia.config.tmp_file_dir)
    file.write(cont)
    file.close
    filepath = file.path
    filename = ds
    ans = @databank.uploadFile(silo, self.dataset, filepath, filename=filename)
    if @databank.responseGood(ans['code'])
      self.msg << "Uploaded file #{ds}"
    else
      self.msg << "Error uploading file #{ds}"
      self.status = false
    end
    file.unlink
  end

  def update_status()
    wf = @obj.workflows.first
    wf.entries.build
    if status
      wf.entries.last.status = Sufia.config.workflow_status["Data migrated"]
    else
      wf.entries.last.status = Sufia.config.workflow_status["System failure"]
    end
    wf.entries.last.creator = "ORA Deposit system"
    wf.entries.last.description = msg.join('\n')
    wf.entries.last.date = Time.now.to_s
  end

  def update_content_datastreams()
    self.content_files.each do |ds, fp|
      filename = File.basename fp
      opts = @obj.datastream_opts(ds)
      oldLoc = opts["dsLocation"]
      # Update file location in datastream
      opts["dsLocation"] = {
        'silo' => self.silo,
        'dataset' => self.dataset,
        'filename' => filename,
        'url' => @databank.getUrl(self.silo, dataset=self.dataset, filename=filename)
      }
      @obj.datastreams[ds].content = opts.to_json
      # delete file
      @obj.delete_file(oldLoc)
    end
    # Delete directory if empty
    if Dir["#{@obj.dir(self.pid)}/*"].empty?
      @obj.delete_dir(self.pid)
    end
  end

  def add_to_next_queue()
    # Add to ora publish queue
    args = {
      'pid' => self.pid,
      'datastreams' => self.datastreams,
      'model' => self.model,
      'numberOfFiles' => self.numberOfFiles
    }
    Resque.redis.rpush(Sufia.config.ora_publish_queue_name, args.to_json)
  end

  def save()
    @obj.save!
  end

end
