class OxfordWorkflow < RDF::Vocabulary("http://vocab.ox.ac.uk/workflow/schema#")
  property :workflow
  property :entry
  property :comment
  
  property :status
  property :reviewer_id
  
  property :Workflow
end

class WorkflowRdfDatastream < ActiveFedora::NtriplesRDFDatastream
  map_predicates do |map|
    map.workflows(to: :workflow, in: OxfordWorkflow, class_name:"Workflow")
  end
  
  def status
    self.workflows.map {|wf| wf.current_status }
  end
  
end

class Workflow
  include ActiveFedora::RdfObject
  rdf_type rdf_type OxfordWorkflow.Workflow
  map_predicates do |map|
    map.identifier(:in => RDF::DC)
    map.entries(to: :entry, :in => OxfordWorkflow, class_name:"WorkflowEntry")
    map.comments(to: :comment, :in => OxfordWorkflow, class_name:"WorkflowComment")
  end
  
  def current_status
    self.entries.last.status.first
  end
  
  def current_reviewer
    self.entries.last.reviewer
  end
end

class WorkflowEntry
  include ActiveFedora::RdfObject
  map_predicates do |map|
    map.date(in: RDF::DC) 
    map.status(in: OxfordWorkflow)
    map.reviewer_id(in: OxfordWorkflow)
  end
  
  def reviewer
    User.find_by_email(self.reviewer_id.first)
  end
end

class WorkflowComment
  include ActiveFedora::RdfObject
  map_predicates do |map|
    map.date(in: RDF::DC) 
    map.creator(in: RDF::DC)
    map.description(in: RDF::DC)
  end
end



