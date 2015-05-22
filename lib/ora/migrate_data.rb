require 'ora/databank'

module ORA
  class MigrateData
  
    attr_reader :dataset, :status, :msg, :silo
  
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
  
    def migrate
      self.create_dataset
      self.upload_to_databank
      self.update_status
      if self.status
        self.update_content_datastreams
      end
      self.save
      if self.status
        self.delete_local_files
        self.add_to_next_queue
      end
    end
  
    private
  
    def create_dataset
      #create dataset in Databank if it doesn't exist
      ans = @databank.getDataset(self.silo, self.dataset)
      unless @databank.responseGood(ans['code'])
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
    
    def upload_to_databank
      # Upload content and metadata files to Databank
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
      # Get file path and file name of content files and upload to Databank.
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
      # Write metadata datastreams to temp files and upload to Databank.
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
  
    def update_status
      #Update the workflow status based on the outcome of create and uploads to Databank
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
  
    def update_content_datastreams
      # Update the content datastreams in the dataset object with the new Databank location of the content files and delete local copy of content file
      self.content_files.each do |ds, fp|
        filename = File.basename fp
        opts = @obj.datastream_opts(ds)
        old_location = opts["dsLocation"]
        # Update file location in datastream
        opts["dsLocation"] = {
          'silo' => self.silo,
          'dataset' => self.dataset,
          'filename' => filename,
          'url' => @databank.getUrl(self.silo, dataset=self.dataset, filename=filename)
        }
        @obj.datastreams[ds].content = opts.to_json
      end
    end

    def delete_local_files
      self.content_files.each do |ds, fp|
        # delete file
        @obj.delete_local_copy(ds, fp)
      end
      # Delete directory if empty
      @obj.delete_dir
    end

    def add_to_next_queue
      # Add to ora publish queue, so record can be published in Ora
      args = {
        'pid' => self.pid,
        'datastreams' => self.datastreams,
        'model' => self.model,
        'numberOfFiles' => self.numberOfFiles
      }
      Resque.redis.rpush(Sufia.config.ora_publish_queue_name, args.to_json)
    end
  
    def save
      # Save changes made to the Dataset object
      @obj.save!
    end
  
  end #class
end #module
