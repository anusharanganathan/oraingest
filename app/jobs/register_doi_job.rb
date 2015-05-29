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
      obj.update_status("System failure", e.message)
      obj.save!
      return
    end
    # validate xml to schema
    begin
      dd.validate_xml(payload)
    rescue ORA::DataValidationError => e
      obj.update_status("System failure", e.message)
      obj.save!
      return
    end
    # Register doi
    dd.call(payload)
    if dd.status
      obj.update_status("DOI registered", dd.msg)
    else
      obj.update_status("System failure", dd.msg)
    end
    obj.save!
  end

end
