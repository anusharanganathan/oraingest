require "datastreams/workflow_rdf_datastream"
class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile
  attr_accessible :workflows, :workflows_attributes
  
  has_metadata :name => "workflowMetadata", :type => WorkflowRdfDatastream
  
  delegate_to "workflowMetadata",  [:workflows, :workflows_attributes]
end