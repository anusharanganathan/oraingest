require "datastreams/workflow_rdf_datastream"
require "datastreams/generic_file_rdf_datastream"
require "person"
require "rdf"

class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile
  attr_accessible *(GenericFileRdfDatastream.fields + [:permissions, :workflows, :workflows_attributes])
  #include Hydra::Collections::Collectible
  #attr_accessible :workflows, :workflows_attributes
  #attr_accessible *(GenericFileRdfDatastream.fields + [:permissions])
  
  before_create :initialize_submission_workflow

  has_metadata :name => "descMetadata", :type => GenericFileRdfDatastream
  has_metadata :name => "workflowMetadata", :type => WorkflowRdfDatastream

  delegate_to "workflowMetadata",  [:workflows, :workflows_attributes], multiple: true
  delegate_to "descMetadata", GenericFileRdfDatastream.fields, multiple: true

  has_and_belongs_to_many :authors, :property=> :has_author, :class_name=>"Person"
  has_and_belongs_to_many :contributors, :property=> :has_contributor, :class_name=>"Person"
  has_and_belongs_to_many :copyright_holders, :property=> :has_copyright_holder, :class_name=>"Person"

  #def to_solr(solr_doc={}, opts={})
  #  super(solr_doc, opts)
  #  solr_doc[Solrizer.solr_name('label')] = self.label
  #  index_collection_pids(solr_doc)
  #  return solr_doc
  #end
  
  private
  
  def initialize_submission_workflow
    if self.workflows.empty?  
      wf = self.workflows.build(identifier:"MediatedSubmission")
      wf.entries.build(status: Sufia.config.draft_status, date: Time.now.to_s)
    end
  end

end
