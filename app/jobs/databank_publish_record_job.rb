require 'ora/databank'
require "fileutils"

class DatabankPublishRecordJob

  def queue_name
    :databank_publish
  end

  attr_accessor :pid, :datastreams, :model, :numberOfFiles, :dataset, :status, :msg, :silo

  def initialize(pid, datastreams, model, numberOfFiles)
    self.pid = pid
    self.datastreams = datastreams
    self.model = model
    self.numberOfFiles = numberOfFiles
    if self.pid.start_with?('uuid:')
      self.dataset = self.pid.sub('uuid:', '')
    else
      self.dataset = self.pid
    end
    self.status = true
    self.msg = []
    @databank = Databank.new(Sufia.config.databank_credentials['host'], username=Sufia.config.databank_credentials['username'], password=Sufia.config.databank_credentials['password'])
    self.silo = Sufia.config.databank_credentials['silo']
  end

  def run
    if self.model == "Article"
      return
    end
    obj = Dataset.find(self.pid)
    # 1. Save metadata datastreams to disk and get list of files
    filenames = {}
    obj.datastreams.keys.each do |ds|
      if ds.start_with?('content')
        opts = obj.datastream_opts(ds)
        filenames[ds] = opts["dsLocation"]
      elsif ds != 'DC'
        cont = obj.datastreams[ds].content
        file = Tempfile.new(ds)
        filenames[ds] = file.path
        file.write(cont)
        file.close
      end
    end
    # 2. Migrate to Databank
    ans = @databank.getDataset(self.silo, self.dataset)
    # Create dataset if needed
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
    # Upload files if dataset exists
    if self.status == true
      filenames.each do |ds,fp|
        if ds.start_with?('content')
          filename = File.basename fp
        else
          filename = ds
        end
        ans = @databank.uploadFile(self.silo, self.dataset, fp, filename=filename)
        if @databank.responseGood(ans['code'])
          self.msg << "Uploaded file #{ds}"
        else
          self.msg << "Error uploading file #{ds}"
          self.status = false
        end
      end
    end
    # 3. Update workflow status
    wf = obj.workflows.first
    wf.entries.build
    if self.status == true
      wf.entries.last.status = Sufia.config.workflow_status["Data migrated"]
    else
      wf.entries.last.status = Sufia.config.workflow_status["System failure"]
    end
    wf.entries.last.reviewer_id = "ORA Deposit system"
    wf.entries.last.description = self.msg.join('\n')
    wf.entries.last.date = Time.now.to_s
    # 4. If succes, update file location in datastream, delete local copy of file and move job to ora_publish queue
    dirname = nil
    if self.status == true
      filenames.each do |ds,fp|
        if ds.start_with?('content')
          filename = File.basename fp
          opts = obj.datastream_opts(ds)
          oldLoc = opts["dsLocation"]
          dirname = File.dirname(oldLoc)
          # Update file location in datastream
          opts["dsLocation"] = @databank.getUrl(self.silo, dataset=self.dataset, filename=filename)
          obj.datastreams[ds].content = opts.to_json
          # delete file
          obj.delete_file(oldLoc)
        end
      end
      # Delete directory if empty
      if !dirname.nil? && Dir["#{dirname}/*"].empty?
        obj.delete_dir(self.pid)
      end
      # Add to ora publish queue
      Sufia.queue.push_raw(PublishRecordJob.new(self.pid, self.datastreams, self.model, self.numberOfFiles))
    end
    # Save object
    obj.save!
    # Delete temporary files created
    filenames.each do |ds,fp|
      if !ds.start_with?('content')
        FileUtils.rm(fp)
      end 
    end
  end

end
