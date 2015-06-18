require 'ora/databank'

module ORA
  class MigrateData
  
    attr_accessor :dataset, :status, :msg, :silo
  
    def initialize(pid, datastreams, model, numberOfFiles)
      @pid = pid
      @datastreams = datastreams
      @model = model
      @numberOfFiles = numberOfFiles
      @content_files = {}
      self.dataset = pid.sub('uuid:', '')
      self.status = true
      self.msg = []
      dc = Sufia.config.databank_credentials
      self.silo = dc['silo']
      @obj = Dataset.find(@pid)
      @databank = Databank.new(dc['host'], username=dc['username'], password=dc['password'], timeout=dc['timeout'])
    end
  
    def migrate
      create_dataset
      upload_to_databank
      update_status
      if self.status
        update_content_datastreams
      end
      save
      if self.status
        delete_local_files
        add_to_next_queue
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
            if filepath
              @content_files[ds] = filepath
            end
          else
            upload_metadata(ds)
          end
        end
      end
    end
  
    def upload_content(ds)
      # Get file path and file name of content files and upload to Databank.
      opts = @obj.datastream_opts(ds)
      filepath = @obj.file_location(ds)
      unless @obj.is_on_disk?(filepath)
        return nil
      end
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
      file.binmode
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
      if self.status
        @obj.workflowMetadata.update_status('Data migrated', self.msg)
      else
        @obj.workflowMetadata.update_status('System failure', self.msg)
      end
    end
  
    def update_content_datastreams
      # Update the content datastreams in the dataset object with the new Databank location of the content files and delete local copy of content file
      @content_files.each do |ds, fp|
        filename = File.basename fp
        # Update file location in datastream
        location = {
          'silo' => self.silo,
          'dataset' => self.dataset,
          'filename' => filename,
          'url' => @databank.getUrl(self.silo, dataset=self.dataset, filename=filename)
        }
        @obj.update_datastream_location(ds, location)
      end
    end

    def delete_local_files
      @content_files.each do |ds, fp|
        # delete file
        @obj.delete_local_copy(ds, fp)
      end
      # Delete directory if empty
      @obj.delete_dir
    end

    def add_to_next_queue
      # Add to ora publish queue, so record can be published in Ora
      args = {
        'pid' => @pid,
        'datastreams' => @datastreams,
        'model' => @model,
        'numberOfFiles' => @numberOfFiles
      }
      Resque.redis.rpush(Sufia.config.ora_publish_queue_name, args.to_json)
    end
  
    def save
      # Save changes made to the Dataset object
      @obj.save!
    end
  
  end #class
end #module
