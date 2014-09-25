#require 'active_support/concern'
require 'rdf'
#Vocabularies
require 'vocabulary/ora'
# Fields
require 'fields/funding_activity'
require 'fields/creation_activity'
require 'fields/titular_activity'
require 'fields/date_duration'

class DatasetAgreementRdfDatastream < ActiveFedora::NtriplesRDFDatastream

  attr_accessor :identifier, :title, :agreementType, :annotation, :digitalSizeAllocated, :dataStorageSilo, :status, :contributor, :references, :valid, :creation, :titularActivity, :invoice, :funding 

  map_predicates do |map|
    map.identifier(:in => RDF::DC)
    map.title(:in => RDF::DC)
    map.type(:in => RDF::DC)
    map.agreementType(:in => RDF::ORA)
    map.annotation(:in => RDF::ORA)
    map.digitalSizeAllocated(:in => RDF::ORA)
    map.dataStorageSilo(:in => RDF::ORA)
    map.status(:to => "agreementStatus", :in => RDF::ORA)
    map.contributor(:in => RDF::DC)
    map.references(:in => RDF::DC)
    map.valid(:in => RDF::DC, class_name:"DateDuration")
    map.creation(:to => "hadCreationActivity", :in => RDF::ORA, class_name:"CreationActivity")
    map.titularActivity(:to => "hadTitularActivity", :in => RDF::ORA, class_name:"TitularActivity")
    map.invoice(:to => "hasInvoice", :in => RDF::ORA, class_name: "InvoiceDetails")
    map.funding(:to => "isOutputOf", :in => RDF::FRAPO, class_name:"FundingActivity")
  end
  accepts_nested_attributes_for :valid
  accepts_nested_attributes_for :creation
  accepts_nested_attributes_for :titularActivity
  accepts_nested_attributes_for :hasInvoice
  accepts_nested_attributes_for :funding

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def to_solr(solr_doc={})
    super
    solr_doc[Solrizer.solr_name("desc_metadata__identifier", :symbol)] = self.identifier
    solr_doc[Solrizer.solr_name("desc_metadata__title", :stored_searchable)] = self.title
    solr_doc[Solrizer.solr_name("desc_metadata__agreementType", :symbol)] = self.agreementType
    solr_doc[Solrizer.solr_name("desc_metadata__digitalSizeAllocated", :symbol)] = self.digitalSizeAllocated
    solr_doc[Solrizer.solr_name("desc_metadata__dataStorageSilo", :stored_searchable)] = self.dataStorageSilo
    solr_doc[Solrizer.solr_name("desc_metadata__dataStorageSilo", :symbol)] = self.dataStorageSilo
    solr_doc[Solrizer.solr_name("desc_metadata__status", :symbol)] = self.status
    solr_doc[Solrizer.solr_name("desc_metadata__contributor", :stored_searchable)] = self.contributor
    solr_doc[Solrizer.solr_name("desc_metadata__references", :symbol)] = self.references
    # Validity date 
    if !self.valid.nil? && !self.valid.first.nil?
      validDate = nil
      if !self.valid.first.end.nil? && !self.valid.first.start.nil?
        validDate = "%s to %s"% [self.valid.first.start.first, self.valid.first.end.first]
      elsif !self.valid.first.start.nil?
        validDate = self.valid.first.start.first
      elsif !self.valid.first.end.nil?
        validDate = self.valid.first.end.first
      end
      if !validDate.nil?
        solr_doc[Solrizer.solr_name("desc_metadata__valid", :stored_searchable)] = validDate
      end
    end
    # Index each creator individually
    self.creation.each do |c|
      c.to_solr(solr_doc)
    end
    # Index each titular activity
    self.titularActivity.each do |c|
      c.to_solr(solr_doc)
    end
    # Index each funding individually
    self.funding.each do |f|
        f.to_solr(solr_doc)
    end
    solr_doc
  end

end

class InvoiceDetails
  include ActiveFedora::RdfObject
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  attr_accessor :identifier, :description, :source, :monetaryValue, :monetaryStatus

  map_predicates do |map|
    map.identifier(:in => RDF::DC)
    map.description(:in => RDF::DC)
    map.source(:in => RDF::DC)
    map.monetaryValue(:in => RDF::ORA)
    map.monetaryStatus(:in => RDF::ORA)
  end

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end

end


