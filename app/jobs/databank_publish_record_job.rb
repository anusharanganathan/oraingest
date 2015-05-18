require 'ora/migrate_data'

class DatabankPublishRecordJob

  @queue = :databank_publish

  def self.perform(pid, datastreams, model, numberOfFiles)
    if model == "Article"
      return
    end
    m = ORA::MigrateData.new(pid, datastreams, model, numberOfFiles)
    m.migrate
  end

end


