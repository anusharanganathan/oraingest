require "datastreams/workflow_rdf_datastream"
require "datastreams/article_rdf_datastream"
#require "person"
require "oxford_terms"
require "rdf"

class Article < ActiveFedora::Base
  include Hydra::AccessControls::Permissions
  include Sufia::GenericFile::AccessibleAttributes
  #include Sufia::GenericFile::WebForm
  #include ModelHelper

  attr_accessible *(ArticleRdfDatastream.fields + [:permissions, :permissions_attributes, :workflows, :workflows_attributes])
  
  before_create :initialize_submission_workflow

  before_save :remove_blank_assertions

  has_metadata :name => "descMetadata", :type => ArticleRdfDatastream
  has_metadata :name => "workflowMetadata", :type => WorkflowRdfDatastream

  delegate_to "workflowMetadata",  [:workflows, :workflows_attributes], multiple: true
  delegate_to "descMetadata", ArticleRdfDatastream.fields, multiple: true

  #has_and_belongs_to_many :authors, :property=> :has_author, :class_name=>"Person"
  #has_and_belongs_to_many :contributors, :property=> :has_contributor, :class_name=>"Person"
  #has_and_belongs_to_many :copyright_holders, :property=> :has_copyright_holder, :class_name=>"Person"

  def to_solr(solr_doc={}, opts={})
    super(solr_doc, opts)
    solr_doc[Solrizer.solr_name('label')] = self.label
    #index_collection_pids(solr_doc)
    return solr_doc
  end

  def apply_permissions(depositor)
    prop_ds = self.datastreams["workflowMetadata"]
    rights_ds = self.datastreams["rightsMetadata"]
    depositor_id = depositor.respond_to?(:user_key) ? depositor.user_key : depositor
    if prop_ds
      #puts "properties of workflow ds ---------------------START"
      #puts prop_ds.methods
      #puts "properties of workflow ds ---------------------END"
      prop_ds.depositor = depositor_id unless prop_ds.nil?
    end
    rights_ds.permissions({:person=>depositor_id}, 'edit') unless rights_ds.nil?
    rights_ds.permissions({:group=>"reviewer"}, 'edit') unless rights_ds.nil?
    return true
  end
  
  private
  
  def initialize_submission_workflow
    if self.workflows.empty?  
      wf = self.workflows.build(identifier:"MediatedSubmission")
      wf.entries.build(status:"Draft", date:Time.now.to_s)
    end
  end

 def remove_blank_assertions
   ArticleRdfDatastream.fields.each do |key|
     #puts "%s, %s"%(key, key.class)
     #if key == 'language'
     #  puts self.language.languageLabel
     #  puts self.language.languageCode
     #  puts self.language.languageAuthority
     #  puts self.language.languageScheme
     #  #if self.language[0].languageLabel.empty?
     #  #   self.language[0].delete(languageLabel)
     #  #end
     #  #if self.language[0].languageScheme.empty?
     #  #   self.language[0].delete(languageScheme)
     #  #end
     #  #self[key].each do |k, v| 
     #  #  self[key].delete(k) if v.empty?
     #  #end
     #else
     #  self[key] = nil if self[key] == ['']
     #end
     self[key] = nil if self[key] == ['']
   end
 end

end
