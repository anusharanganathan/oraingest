require 'vocabulary/pwo'
require 'ora/rt_client'

class OxfordWorkflow < RDF::Vocabulary("http://vocab.ox.ac.uk/workflow/schema#")
  property :depositor
  property :workflow
  property :entry       # same as PWO.hasStep. Is of type PWO.Step
  property :comment     # is of type owl entity
  property :status
  property :reviewer_id
  property :Workflow    # same as PWO.Workflow
  property :emailThread # is of type owl entity
end

class WorkflowRdfDatastream < ActiveFedora::NtriplesRDFDatastream
  map_predicates do |map|
    # Depositor
    map.depositor(to: :depositor, :in => OxfordWorkflow)
    # Workflows
    map.workflows(to: :workflow, in: OxfordWorkflow, class_name:"Workflow")
  end
  
  accepts_nested_attributes_for :workflows
  
  def current_statuses
    self.workflows.map {|wf| wf.current_status }
  end

  def send_email(wf_id, data, user, model)
    # data hash to include record_id and record_url 
    # If ticket was created successfully, should return ticket number
    # if there was an error getting the content, should return false
    # If no email is configured to be sent, should return nil
    wf = self.workflows.select{|wf| wf.identifier.first == wf_id}.first
    if wf && Sufia.config.email_options.keys.include?(model.downcase) && Sufia.config.email_options[model.downcase].include?(wf.current_status)
      occurences = wf.all_statuses.select{|s| s == wf.current_status}
      occurence = Sufia.config.email_options[model.downcase][wf.current_status]['occurence']
      template = Sufia.config.email_options[model.downcase][wf.current_status]['template']
      subject = Sufia.config.email_options[model.downcase][wf.current_status]['subject'].gsub('ID', data['record_id'])
      if (occurence == occurences.length) || occurence == "all"
        rt = Ora::RtClient.new
        user_info = user.user_info
        user_name = user.display_name(user_info) || user.name
        content = rt.email_content(template, data, user_name)
        if content
          ans = rt.create_ticket(subject, user.oxford_email(user_info), content)
          is_number = true if Float(ans) rescue false
          if ans and is_number
            #email_params = { :id => wf.rdf_subject.to_s }
            #email_params[:emailThreads_attributes] = [{:identifier => ans, :references => "#{Sufia.config.rt_server}Ticket/Display.html?id=#{ans}", :date => Time.now.to_s}]
            #return email_params
            wf.emailThreads.build(identifier:ans, references:"#{Sufia.config.rt_server}Ticket/Display.html?id=#{ans}", date:Time.now.to_s)
          end
        end
      end
    end
  end 

  def update_status(status, description, creator='ORA Deposit system', wf_id="MediatedSubmission")
    #Update the workflow status. Add a new workflow entry.
    unless Sufia.config.workflow_status.include?(status)
      return false
    end
    wf = self.workflows.select{|wf| wf.identifier.first == wf_id}.first
    wf.entries.build
    wf.entries.last.status = status
    wf.entries.last.creator = creator
    if description.is_a?(Array)
      description = description.join('\n')
    end
    wf.entries.last.description = description
    wf.entries.last.date = Time.now.to_s
    return true
  end
  
  def to_solr(solr_doc={})
    super
    solr_doc[Solrizer.solr_name("all_workflow_statuses", :symbol)] = self.current_statuses
    solr_doc[Solrizer.solr_name("depositor", :stored_searchable)] = self.depositor
    # Indexes each workflow individually using the :identifier to build a workflow-specific solr field name.  
    # If multiple workflow nodes are using the same :identifier, only the first one will be indexed.
    self.workflows.each do |wf|
      already_indexed = []
      unless wf.identifier.empty? || already_indexed.include?(wf.identifier.first)
        wf.to_solr(solr_doc) 
        already_indexed << wf.identifier.first
      end
    end
    solr_doc
  end
  
end

class Workflow
  include ActiveFedora::RdfObject
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  rdf_type rdf_type OxfordWorkflow.Workflow 
  map_predicates do |map|
    map.identifier(:in => RDF::DC)
    map.entries(to: :entry, :in => OxfordWorkflow, class_name:"WorkflowEntry")
    map.comments(to: :comment, :in => OxfordWorkflow, class_name:"WorkflowComment")
    map.emailThreads(to: :emailThread, :in => OxfordWorkflow, class_name:"WorkflowCommunication")
    map.produces(:in => RDF::PWO)
    map.involves(to: :involvesEvent, :in => RDF::PWO)
  end
  
  accepts_nested_attributes_for :entries, :comments, :emailThreads
  
  def current_status
    if self.entries.empty?
      return nil
    else
      return self.entries.last.status.first 
    end
  end
  
  def all_statuses
    if self.entries.empty?
      return nil
    else
      return self.entries.map{|e| e.status.first}.reject{|v| v.nil? || v.empty? }
    end
  end

  # Returns the User matching the reviewer id on last entry in the workflow
  # Returns nil if no reviewer_id available or if the reviewer_id does not match any existing Users
  def current_reviewer
    if self.entries.empty?
      return nil
    else
      self.entries.last.reviewer
    end
  end

  # Returns the (String) id of current reviewer on last entry
  # Returns nil if no value to return
  def current_reviewer_id
    if self.entries.empty?
      return nil
    else
      selected_entries = self.entries.select{|e| e.status.first != Sufia.config.draft_status && e.status.first != Sufia.config.submitted_status}
      if selected_entries.empty?
        return nil
      else
        return selected_entries.last.creator.first
      end
      #self.entries.last.reviewer_id.first
    end
  end
  
  # The entry marking when the User submitted an item into workflow
  def submission_entry
    self.entries.select{|e| e.status == [Sufia.config.submitted_status]}.first
  end
  
  # The date value from the esubmission_entry
  def date_submitted
    unless submission_entry.nil?
      submission_entry.date.first
    end
  end

  def persisted?
    false
  end
  
  def to_solr(solr_doc)
    solr_doc[Solrizer.solr_name(self.identifier.first+"_status", :symbol)] = self.current_status 
    solr_doc[Solrizer.solr_name(self.identifier.first+"_current_reviewer_id", :symbol)] = self.current_reviewer_id
    solr_doc[Solrizer.solr_name(self.identifier.first+"_all_reviewer_ids", :symbol)] = self.entries.map{|e| e.creator.first if (e.status.first != Sufia.config.draft_status && e.status.first != Sufia.config.submitted_status) }.uniq.reject{|v| v.nil? || v.empty? }
    solr_doc[Solrizer.solr_name(self.identifier.first+"_all_email_threads", :symbol)] = self.emailThreads.map{|e| e.identifier.first }.uniq.reject{|v| v.nil? || v.empty? }
    unless self.date_submitted.nil?
      begin
        solr_doc[Solrizer.solr_name(self.identifier.first+"_date_submitted", :dateable)] = Time.parse(self.date_submitted).utc.iso8601
      rescue ArgumentError
        # This means the date_submitted value is not a valid date.  Don't put it into the solr doc, or solr will choke.
      end
    end
  end
end

class WorkflowEntry
  include ActiveFedora::RdfObject
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  rdf_type rdf_type RDF::PWO.Step 
  map_predicates do |map|
    map.date(in: RDF::DC) 
    map.status(in: OxfordWorkflow)
    map.reviewer_id(in: OxfordWorkflow)
    map.creator(in: RDF::DC)
    map.description(in: RDF::DC)
  end
  
  # Returns the User matching the reviewer id on the entry
  # Returns nil if no reviewer_id available or if the reviewer_id does not match any existing Users
  def reviewer
    User.find_by_email(self.reviewer_id.first)
  end
  
  def persisted?
    false
  end
  
end

class WorkflowComment
  include ActiveFedora::RdfObject
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  map_predicates do |map|
    map.date(in: RDF::DC) 
    map.creator(in: RDF::DC)
    map.description(in: RDF::DC)
  end
  
  def persisted?
    false
  end
  
end

class WorkflowCommunication
  include ActiveFedora::RdfObject
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  map_predicates do |map|
    map.identifier(in: RDF::DC)
    map.date(in: RDF::DC) 
    map.references(in: RDF::DC)
  end
  
  def persisted?
    false
  end
  
end


