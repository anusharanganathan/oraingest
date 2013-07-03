require "datastreams/workflow_rdf_datastream"
class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile
  has_metadata :name => "workflowMetadata", :type => WorkflowRdfDatastream
end