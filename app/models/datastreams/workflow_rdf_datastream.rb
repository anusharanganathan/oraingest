class OxfordWorkflow < RDF::Vocabulary("http://vocab.ox.ac.uk/workflow/schema#")
  property :depositor
  property :workflow
  property :entry
  property :comment
  
  property :status
  property :reviewer_id
  
  property :Workflow
  property :emailThread
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
  end
  
  accepts_nested_attributes_for :entries, :comments, :emailThreads
  
  def current_status
    if self.entries.empty?
      return nil
    else
      return self.entries.last.status.first 
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
      selected_entries = self.entries.select{|e| e.status.first != "Draft" && e.status.first != "Submitted"}
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
    self.entries.select{|e| e.status == ["Submitted"]}.first
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
    solr_doc[Solrizer.solr_name(self.identifier.first+"_all_reviewer_ids", :symbol)] = self.entries.map{|e| e.creator.first if (e.status.first != "Draft" && e.status.first != "Submitted") }.uniq.reject{|v| v.nil? || v.empty? }
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
end


