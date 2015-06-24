require 'ora/data_doi'

class RegisterDoiJob

  @queue = :register_doi

  def self.perform(pid)
    obj = Dataset.find(pid)
    unless obj.doi_requested?
      return
    end
    payload = obj.doi_data
    dd = ORA::DataDoi.new(Sufia.config.doi_credentials)
    # validate required fields
    begin
      dd.validate_required(payload)
    rescue ORA::DataValidationError => e
      obj.workflowMetadata.update_status(Sufia.config.failure_status, e.message)
      obj.save!
      return
    end
    # validate xml to schema
    begin
      dd.validate_xml(payload)
    rescue ORA::DataValidationError => e
      obj.workflowMetadata.update_status(Sufia.config.failure_status, e.message)
      obj.save!
      return
    end
    # Register doi
    dd.call(payload)
    if dd.status
      obj.workflowMetadata.update_status(Sufia.config.doi_status, dd.msg)
    else
      obj.workflowMetadata.update_status(Sufia.config.failure_status, dd.msg)
    end
    obj.save!
  end

end
