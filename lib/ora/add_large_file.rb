module Ora

  module_function

  def addLargeFile(pid, filepath)
    @dataset = Dataset.find(pid)
    @file = File.open(filepath)
    filename = File.basename(@file)
    location = @dataset.save_file(file, @dataset.id, filename)
    dsid = @dataset.save_file_associated_datastream(filename, location, @file.size)
    @dataset.save_file_metadata(location, @file.size)
    # Set the medium to digital in metadata
    @dataset.medium = Sufia.config.data_medium["Digital"]
    #Set the title of the dataset if it is empty or nil
    if @dataset.title.nil? || @dataset.title.empty? || @dataset.title.first.empty?
      @dataset.title = filename
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
