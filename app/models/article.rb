require "datastreams/workflow_rdf_datastream"
require "datastreams/article_rdf_datastream"
require "datastreams/relations_rdf_datastream"
require "datastreams/article_admin_rdf_datastream"
#require "person"
require "rdf"

class Article < ActiveFedora::Base
  include Hydra::AccessControls::Permissions
  include Sufia::GenericFile::AccessibleAttributes
  #include Sufia::GenericFile::WebForm
  include Sufia::Noid
  include Hydra::ModelMethods
  include DoiMethods
  include ContentMethods

  attr_accessible *(ArticleRdfDatastream.fields + RelationsRdfDatastream.fields + [:permissions, :permissions_attributes, :workflows, :workflows_attributes] + ArticleAdminRdfDatastream.fields)
  
  before_create :initialize_submission_workflow

  before_save :remove_blank_assertions

  has_metadata :name => "descMetadata", :type => ArticleRdfDatastream
  has_metadata :name => "workflowMetadata", :type => WorkflowRdfDatastream
  has_metadata :name => "relationsMetadata", :type => RelationsRdfDatastream
  has_metadata :name => "adminMetadata", :type => ArticleAdminRdfDatastream
  has_file_datastream "content01"

  has_attributes :workflows, :workflows_attributes, datastream: :workflowMetadata, multiple: true
  has_attributes *ArticleRdfDatastream.fields, datastream: :descMetadata, multiple: true
  has_attributes *RelationsRdfDatastream.fields, datastream: :relationsMetadata, multiple: true
  has_attributes *ArticleAdminRdfDatastream.fields, datastream: :adminMetadata, multiple: true
  #has_and_belongs_to_many :authors, :property=> :has_author, :class_name=>"Person"
  #has_and_belongs_to_many :contributors, :property=> :has_contributor, :class_name=>"Person"

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
      prop_ds.depositor = depositor_id unless prop_ds.nil?
    end
    rights_ds.permissions({:person=>depositor_id}, 'edit') unless rights_ds.nil?
    rights_ds.permissions({:group=>"reviewer"}, 'edit') unless rights_ds.nil?
    return true
  end
  
  def to_jq_upload(title, size, pid, dsid)
    return {
      "name" => title, #self.title,
      "size" => size, #self.file_size,
      "url" => "/articles/#{pid}/file/#{dsid}", #"/article/#{noid}",
      "thumbnail_url" => thumbnail_url(title, '48'),#self.pid,
      "delete_url" => "/articles/#{pid}/file/#{dsid}", #"/article/#{noid}",
      "delete_type" => "DELETE"
    }
  end

  def mint_datastream_id
    choicesUsed = self.datastreams.keys.select { |key| key.match(/^content\d+/) and self.datastreams[key].content != nil }
    begin
      "content%02d"%(choicesUsed[-1].last(2).to_i+1)
    rescue
      "content01"
    end
  end

  def model_klass
    self.class.model_name.to_s
  end

  private
  
  def initialize_submission_workflow
    if self.workflows.empty?  
      wf = self.workflows.build(identifier:"MediatedSubmission")
      wf.entries.build(status:Sufia.config.draft_status, date:Time.now.to_s)
    end
  end

  def remove_blank_assertions
    ArticleRdfDatastream.fields.each do |key|
      self[key] = nil if self[key] == ['']
    end
  end

  def self.find_or_create(pid)
    begin
      Article.find(pid)
    rescue ActiveFedora::ObjectNotFoundError
      Article.create({pid: pid})
    end
  end

end
