module Ora

  module_function

  def addLargeFile(pid, filepath)

    @dataset = Dataset.find(pid)
    @file =    File.open(filepath)

    dsid = "content%s"% Sufia::Noid.noidify(Sufia::IdService.mint)

    # create the file path to save
    file_name = File.basename(@file) 
    if pid.include?('sufia:')
      pid = pid.gsub('sufia:', '')
    end
    directory = File.join(Sufia.config.data_root_dir, pid)
    FileUtils::mkdir_p(directory) 
    location = File.join(directory, file_name)

    #If the file exists, append a count to the filename
    extn = File.extname(location)
    fn = File.basename(location, extn)
    dirname = File.dirname(location)
    count = 0
    while File.file?(location)
      count += 1
      fnNew = "#{fn}-#{count}"
      location = File.join(dirname,"#{fnNew}#{extn}")
    end

    # write the file
    File.open(location, "wb") { |f| f.write(@file.read) }

    # Add the file location to the metadata
    if !@dataset.adminLocator.include?(File.dirname(location))
      @dataset.adminLocator << File.dirname(location)
    end

    # Increment total file size in metadata
    size = Integer(@dataset.adminDigitalSize.first) rescue 0
    @dataset.adminDigitalSize = size + @file.size

    # Set the medium to digital in metadata
    @dataset.medium = Sufia.config.data_medium["Digital"]

    # Prepare data for associated datastream
    mime_types = MIME::Types.of(filepath)
    mime_type = mime_types.empty? ? "application/octet-stream" : mime_types.first.content_type
    opts = {:dsLabel => file_name, :controlGroup => "E", :dsLocation=>location, :mimeType=>mime_type, :dsid=>dsid, :size=>@file.size}

    # Add the datastream associated to the file
    dsfile = StringIO.new(opts.to_json)
    @dataset.add_file(dsfile, dsid, "attributes.json")

    #Set the title of the dataset if it is empty or nil
    if @dataset.title.nil? || @dataset.title.empty? || @dataset.title.first.empty?
      @dataset.title = file.original_filename
    end

    # Save the dataset
    save_tries = 0
    begin
      @dataset.save!
    rescue RSolr::Error::Http => error
      save_tries+=1
      # fail for good if the tries is greater than 3
      raise error if save_tries >=3
      sleep 0.01
      retry
    end

  end #addLargeFile

end #module ORA
