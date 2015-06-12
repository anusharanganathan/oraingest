module Ora

  module_function

  def addLargeFile(pid, filepath)
    @dataset = Dataset.find(pid)
    @file = File.open(filepath)
    filename = File.basename(@file)
    dsid = @dataset.add_content(@file, filename)
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
