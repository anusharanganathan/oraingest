#Sufia.queue.push(ContentDepositorChangeEventJob.new(pid, on_behalf_of)) if on_behalf_of.present?
#Sufia.queue.push(CreateDerivativesJob.new(generic_file.id))
#Sufia.queue.push(ContentDepositEventJob.new(generic_file.pid, user.user_key))
#Sufia.queue.push(ContentRestoredVersionEventJob.new(generic_file.pid, 
#Sufia.queue.push(ImportUrlJob.new(gf.pid))
#rails console
#$redis = Redis.new(:host => 'localhost', :port => 6379)
#$redis.keys
#Sufia.queue.push(PublishRecordJob.new(

#pid = "uuid:eb27873c-3337-4ab3-9939-01bb11c3e4f1" # No access info at all
#pid = "sufia:6d56zw62k" # Some datastreams do not have access info
#pid = "sufia:6d56zw69h" # All access info available

#record = Dataset.find(pid)

module Ora
  module_function

  def publishRecord(record, current_user)
    # Send pid and list of open datastreams to queue
    # If datastreams are empty, that means record is all dark
    unless record.workflows.first.current_status == "Approved" 
      # Cannot publish as not approved. Add comment and return
      msg = "Record cannot be processed until approved. Current status is #{record.workflows.first.current_status}."
      comment = {:description => msg, :creator => current_user, :date => Time.now.to_s}
      record.workflows.first.comments.build(comment)
    else
      toMigrate = false
      msg = []
      datastreams = []
      #Get list of all datastreams without access rights
      conts = record.datastreams.keys.select { |key| key.start_with?('content') and record.datastreams[key].content != nil }
      record.hasPart.each do |hp|
        if (conts.include? hp.identifier[0]) && (!hp.accessRights.nil? && !hp.accessRights[0].embargoStatus.nil? && !hp.accessRights[0].embargoStatus[0].nil? && !hp.accessRights[0].embargoStatus[0].empty?)
          conts.delete(hp.identifier[0])
        end
      end
      # If access rights not defined for file or catalogue record, mark as system failure
      if !conts.empty? || record.accessRights.nil? || record.accessRights[0].embargoStatus.nil?
        status = "System failure"
        if record.accessRights.nil? || record.accessRights[0].embargoStatus.nil?
          msg << "No embargo details for catalogue record."
        end
        if !conts.empty?
          conts.each do |ds|
            msg << "No embargo details for #{ds}."
          end
        end
      # If catalogue record is open access, gather datastreams to migrate
      elsif record.accessRights[0].embargoStatus[0] == "Open access"
        if record.datastreams.keys().include? "descMetadata"
          status = "Migrate"
          toMigrate = true
          datastreams << "descMetadata"
          if record.datastreams.keys().include? "relationsMetadata"
            datastreams << "relationsMetadata"
          end
          record.hasPart.each do |hp|
            if hp.accessRights[0].embargoStatus[0] == "Open access"
              datastreams << "#{hp.identifier[0]}"
            end
          end
          msg << "Datastreams to migrate: %s."%datastreams.join(", ")
        else
          msg << "No descMetadata available."
          status = "System failure"
        end
      # If catalogue record is not open access, no datastreams to gather
      elsif record.accessRights[0].embargoStatus[0] != "Open access"
        toMigrate = true
        status = "Migrate" #Set to Migrate, depending on archive policy
        msg << "Catalogue record is #{record.accessRights[0].embargoStatus[0]}."
      end
      # Update status of object
      entry = {:description => msg.join(" "), :creator => current_user, :date => Time.now.to_s, :status => status}
      record.workflows.first.entries.build(entry)
      # Push object to queue
      if toMigrate
        Sufia.queue.push(PublishRecordJob.new(record.id.to_s, datastreams, record.class.model_name))
      end
    end
    #record.save()
    return record
  end

end
