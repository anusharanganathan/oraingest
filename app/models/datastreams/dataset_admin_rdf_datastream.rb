#require 'active_support/concern'
require 'rdf'
require 'vocabulary/ora'
require 'vocabulary/bibo'

class DatasetAdminRdfDatastream < ActiveFedora::NtriplesRDFDatastream

  attr_accessor :hasAgreement, :storageAgreement, :note, :adminLocator, :adminDigitalSize

  map_predicates do |map|
    # For internal relations
    map.hasDataManagementPlan(:in => RDF::ORA)
    map.hasAgreement(:in => RDF::ORA)
    map.storageAgreement(:in => RDF::ORA, class_name:"AgreementDetails")
    map.note(:to => "annotation", :in => RDF::ORA)
    map.adminLocator(:to => "locator", :in => RDF::ORA)
    map.adminDigitalSize(:to => "digitalSize", :in => RDF::ORA)
  end
  accepts_nested_attributes_for :storageAgreement

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def to_solr(solr_doc={})
    super
    solr_doc[Solrizer.solr_name("admin_metadata__hasAgreement", :symbol)] = self.hasAgreement
    if !self.storageAgreement.nil? && !self.storageAgreement.first.nil?
      solr_doc[Solrizer.solr_name("admin_metadata__agreementTitle", :stored_searchable)] = self.storageAgreement.first.title.first
      solr_doc[Solrizer.solr_name("admin_metadata__agreementIdentifier", :symbol)] = self.storageAgreement.first.identifier.first
    end
    solr_doc[Solrizer.solr_name("admin_metadata__locator", :stored_searchable)] = self.adminLocator
    solr_doc[Solrizer.solr_name("admin_metadata__digitalSize", :symbol)] = self.adminDigitalSize
    solr_doc
  end

end

class AgreementDetails
  include ActiveFedora::RdfObject
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  attr_accessor :identifier, :title

  map_predicates do |map|
    map.identifier(:in => RDF::DC)
    map.title(:in => RDF::DC)
  end

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end

end

