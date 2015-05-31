require "datastreams/dataset_agreement_rdf_datastream"
require "datastreams/relations_rdf_datastream"
require "dataset"
#require "person"
require "rdf"

class DatasetAgreement < ActiveFedora::Base
  include Hydra::AccessControls::Permissions
  include Sufia::GenericFile::AccessibleAttributes
  #include Sufia::GenericFile::WebForm
  include Sufia::Noid
  include Hydra::ModelMethods

  attr_accessible *(DatasetAgreementRdfDatastream.fields + RelationsRdfDatastream.fields + [:permissions, :permissions_attributes])
  
  before_save :remove_blank_assertions

  has_metadata :name => "descMetadata", :type => DatasetAgreementRdfDatastream
  has_metadata :name => "relationsMetadata", :type => RelationsRdfDatastream

  has_many :datasets, :property=>:has_agreement, :class_name=>"Dataset"

  has_attributes *DatasetAgreementRdfDatastream.fields, datastream: :descMetadata, multiple: true
  has_attributes *RelationsRdfDatastream.fields, datastream: :relationsMetadata, multiple: true

  #has_and_belongs_to_many :authors, :property=> :has_author, :class_name=>"Person"
  #has_and_belongs_to_many :contributors, :property=> :has_contributor, :class_name=>"Person"

  def to_solr(solr_doc={}, opts={})
    super(solr_doc, opts)
    solr_doc[Solrizer.solr_name('label')] = self.label
    return solr_doc
  end

  def apply_permissions(depositor)
    rights_ds = self.datastreams["rightsMetadata"]
    depositor_id = depositor.respond_to?(:user_key) ? depositor.user_key : depositor
    rights_ds.permissions({:person=>depositor_id}, 'edit') unless rights_ds.nil?
    rights_ds.permissions({:group=>"reviewer"}, 'edit') unless rights_ds.nil?
    #rights_ds.permissions({:group=>"registered"}, 'discover') unless rights_ds.nil?
    rights_ds.permissions({:group=>"registered"}, 'read') unless rights_ds.nil?
    return true
  end
  
  def to_jq_upload(title, size, pid, dsid)
    return {
      "name" => title, #self.title,
      "size" => size, #self.file_size,
      "url" => "/dataset_agreements/#{pid}/file/#{dsid}", #"/dataset/#{noid}",
      "thumbnail_url" => thumbnail_url(title, '48'),#self.pid,
      "delete_url" => "/dataset_agreements/#{pid}/file/#{dsid}", #"/dataset/#{noid}",
      "delete_type" => "DELETE"
    }
  end

  def model_klass
    self.class.model_name.to_s
  end

  private
  
  def remove_blank_assertions
    DatasetAgreementRdfDatastream.fields.each do |key|
      if !["creation", "hasInvoice", "funding"].include?(key)
        self[key] = nil if self[key] == ['']
      end
    end
  end

  def self.find_or_create(pid)
    begin
      DatasetAgreement.find(pid)
    rescue ActiveFedora::ObjectNotFoundError
      DatasetAgreement.create({pid: pid})
    end
  end

  def thumbnail_url(filename, size)
    icon = "fileIcons/default-icon-#{size}x#{size}.png"
    begin
      mt = MIME::Types.of(filename)
      extensions = mt[0].extensions
    rescue
      extensions = []
    end
    for ext in extensions
      if Rails.application.assets.find_asset("fileIcons/#{ext}-icon-#{size}x#{size}.png")
        icon = "fileIcons/#{ext}-icon-#{size}x#{size}.png"
      end
    end
    icon
  end

end
