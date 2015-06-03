class Thesis < ActiveFedora::Base
  include Hydra::AccessControls::Permissions
  include Sufia::GenericFile::AccessibleAttributes
  include Sufia::Noid
  include Hydra::ModelMethods
  include DoiMethods
  include ContentMethods

  attr_accessible *(ThesisRdfDatastream.fields + RelationsRdfDatastream.fields + [:permissions, :permissions_attributes, :workflows, :workflows_attributes] + ThesisAdminRdfDatastream.fields)

  before_create :initialize_submission_workflow
  before_save :remove_blank_assertions

  has_metadata :name => "descMetadata", :type => ThesisRdfDatastream
  has_metadata :name => "workflowMetadata", :type => WorkflowRdfDatastream
  has_metadata :name => "relationsMetadata", :type => RelationsRdfDatastream
  has_metadata :name => "adminMetadata", :type => ThesisAdminRdfDatastream

  has_attributes :workflows, :workflows_attributes, datastream: :workflowMetadata, multiple: true
  has_attributes *ThesisRdfDatastream.fields, datastream: :descMetadata, multiple: true
  has_attributes *RelationsRdfDatastream.fields, datastream: :relationsMetadata, multiple: true
  has_attributes *ThesisAdminRdfDatastream.fields, datastream: :adminMetadata, multiple: true

  def to_solr(solr_doc={}, opts={})
    super(solr_doc, opts)
    solr_doc[Solrizer.solr_name('label')] = self.label
    return solr_doc
  end

  def apply_permissions(depositor)
    prop_ds = self.datastreams["workflowMetadata"]
    rights_ds = self.datastreams["rightsMetadata"]
    depositor_id = depositor.respond_to?(:user_key) ? depositor.user_key : depositor
    prop_ds.depositor = depositor_id unless prop_ds.nil?
    rights_ds.permissions({:person=>depositor_id}, 'edit') unless rights_ds.nil?
    rights_ds.permissions({:group=>"reviewer"}, 'edit') unless rights_ds.nil?
    return true
  end

  def self.find_or_create(pid)
    begin
      Thesis.find(pid)
    rescue ActiveFedora::ObjectNotFoundError
      Thesis.create({pid: pid})
    end
  end

  def to_jq_upload(title, size, pid, dsid)
    return {
        "name" => title, #self.title,
        "size" => size, #self.file_size,
        "url" => "/theses/#{pid}/file/#{dsid}", #"/thesis/#{noid}",
        "thumbnail_url" => thumbnail_url(title, '48'),#self.pid,
        "delete_url" => "/theses/#{pid}/file/#{dsid}", #"/thesis/#{noid}",
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
    if workflows.empty?
      wf = workflows.build(identifier:"MediatedSubmission")
      wf.entries.build(status:"Draft", date:Time.now.to_s)
    end
  end

  def remove_blank_assertions
    ThesisRdfDatastream.fields.each do |key|
      self[key] = nil if self[key] == ['']
    end
  end

end