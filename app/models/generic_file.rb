require "datastreams/workflow_rdf_datastream"
require "datastreams/generic_file_rdf_datastream"
require "person"
require "oxford_terms"
require "rdf"

class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile
  attr_accessible :workflows, :workflows_attributes 

  has_metadata :name => "descMetadata", :type => GenericFileRdfDatastream
  has_metadata :name => "workflowMetadata", :type => WorkflowRdfDatastream

  delegate_to "workflowMetadata",  [:workflows, :workflows_attributes] 

  #has_many :authors, :property=> :has_author, :class_name=>"Person"
  #has_many :contributors, :property=> :has_contributor, :class_name=>"Person"
  #has_many :copyright_holders, :property=> :has_copyright_holder, :class_name=>"Person"

  has_and_belongs_to_many :authors, :property=> :has_author, :class_name=>"Person"
  has_and_belongs_to_many :contributors, :property=> :has_contributor, :class_name=>"Person"
  has_and_belongs_to_many :copyright_holders, :property=> :has_copyright_holder, :class_name=>"Person"
end
