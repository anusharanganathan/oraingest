require "datastreams/workflow_rdf_datastream"
require "datastreams/generic_file_rdf_datastream"
require "person"
require "oxford_terms"
require "rdf"

class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile
  attr_accessible :workflows, :workflows_attributes
  before_create :initialize_submission_workflow

  has_metadata :name => "descMetadata", :type => GenericFileRdfDatastream
  has_metadata :name => "workflowMetadata", :type => WorkflowRdfDatastream

  delegate_to "workflowMetadata",  [:workflows, :workflows_attributes] 
  delegate_to "descMetadata", GenericFileRdfDatastream.fields

  has_and_belongs_to_many :authors, :property=> :has_author, :class_name=>"Person"
  has_and_belongs_to_many :contributors, :property=> :has_contributor, :class_name=>"Person"
  has_and_belongs_to_many :copyright_holders, :property=> :has_copyright_holder, :class_name=>"Person"
  
  private
  
  def initialize_submission_workflow
    if self.workflows.empty?  
      wf = self.workflows.build(identifier:"MediatedSubmission")
      wf.entries.build(status:"Draft", date:Time.now.to_s)
    end
  end

end