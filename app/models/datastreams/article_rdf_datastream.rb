#require 'active_support/concern'
require 'rdf'
#require 'datastreams/person_rdf_datastream'
#Vocabularies
require 'vocabulary/bibo'
require 'vocabulary/camelot'
require 'vocabulary/ora'
require 'vocabulary/dams'
require 'vocabulary/frapo'
# Fields
require 'fields/mads_language'
require 'fields/mads_subject'
require 'fields/work_type'
require 'fields/rights_activity'
require 'fields/funding_activity'
require 'fields/creation_activity'
require 'fields/publication_activity'

class ArticleRdfDatastream < ActiveFedora::NtriplesRDFDatastream
  #include ModelHelper

  attr_accessor :title, :subtitle, :abstract, :subject, :keyword, :worktype, :medium, :language, :publicationStatus, :reviewStatus, :license, :dateCopyrighted, :rightsHolder, :rights, :rightsActivity, :creation, :funding, :publication

  rdf_type rdf_type RDF::PROV.Entity
  map_predicates do |map|
    #-- title --
    map.title(:in => RDF::DC)
    #-- subtitle --
    map.subtitle(:in => RDF::DAMS)
    #-- abstract --
    map.abstract(:in => RDF::DC)
    #-- subject --
    map.subject(:in => RDF::DC, class_name:"MadsSubject")
    #-- keyword --
    map.keyword(:in => RDF::CAMELOT)
    #-- type --
    map.worktype(:to=>"type", :in => RDF::DC, class_name:"WorkType")
    #-- medium --
    map.medium(:in => RDF::DC)
    #-- language --
    map.language(:in => RDF::DC, class_name:"MadsLanguage")
    # -- publication status -- 
    #TODO: Check if this is used. May be replaced by one in publication activity
    map.publicationStatus(:to => "DocumentStatus", :in => RDF::BIBO)
    # -- review status --
    #TODO: Check if this is used. May be replaced by one in publication activity
    map.reviewStatus(:in => RDF::ORA)
    # -- rights activity --
    map.license(:in => RDF::DC, class_name:"LicenseStatement")
    map.dateCopyrighted(:in => RDF::DC)
    map.rightsHolder(:in => RDF::DC)
    map.rights(:in => RDF::DC, class_name:"RightsStatement")
    map.rightsActivity(:in => RDF::PROV, :to => "hadActivity", class_name:"RightsActivity")
    # -- creation activity --
    # TODO: link with Fedora person objects
    map.creation(:to => "hadCreationActivity", :in => RDF::ORA, class_name:"CreationActivity")
    # -- funding activity --
    # TODO: Lookup and link with Fedora funder objects
    map.funding(:to => "isOutputOf", :in => RDF::FRAPO, class_name:"FundingActivity")
    #-- publication activity --
    map.publication(:to => "hadPublicationActivity", :in => RDF::ORA, class_name:"PublicationActivity")
    # -- Commissioning body --
    # TODO: Nested attributes using Prov
    #-- source --
    # TODO: Nested attributes of name, homepage and uri - one to many

  end
  accepts_nested_attributes_for :language
  accepts_nested_attributes_for :subject
  accepts_nested_attributes_for :worktype
  accepts_nested_attributes_for :license
  accepts_nested_attributes_for :rights
  accepts_nested_attributes_for :rightsActivity
  accepts_nested_attributes_for :creation
  accepts_nested_attributes_for :funding
  accepts_nested_attributes_for :publication

  def to_solr(solr_doc={})
    solr_doc[Solrizer.solr_name("desc_metadata__title", :stored_searchable)] = self.title
    solr_doc[Solrizer.solr_name("desc_metadata__subtitle", :stored_searchable)] = self.subtitle
    solr_doc[Solrizer.solr_name("desc_metadata__abstract", :stored_searchable)] = self.abstract
    solr_doc[Solrizer.solr_name("desc_metadata__keyword", :stored_searchable)] = self.keyword
    solr_doc[Solrizer.solr_name("desc_metadata__medium", :stored_searchable)] = self.medium
    solr_doc[Solrizer.solr_name("desc_metadata__publicationStatus", :stored_searchable)] = self.publicationStatus
    solr_doc[Solrizer.solr_name("desc_metadata__reviewStatus", :stored_searchable)] = self.reviewStatus
    #solr_doc[Solrizer.solr_name("dateCopyrighted", :stored_searchable, type: :date)] = self.dateCopyrighted
    # Need to validate data and convert it to proper date format before indexing as date
    solr_doc[Solrizer.solr_name("desc_metadata__dateCopyrighted", :stored_searchable)] = self.dateCopyrighted
    solr_doc[Solrizer.solr_name("desc_metadata__rightsHolder", :stored_searchable)] = self.rightsHolder
    # Index the type of work
    self.worktype.each do |w|
      already_indexed = []
      unless w.typeLabel.empty? || already_indexed.include?(w.typeLabel.first)
        w.to_solr(solr_doc)
        already_indexed << w.typeLabel.first
      end
    end
    # Index each language individually
    self.language.each do |l|
      already_indexed = []
      unless l.languageLabel.empty? || already_indexed.include?(l.languageLabel.first)
        l.to_solr(solr_doc)
        already_indexed << l.languageLabel.first
      end
    end
    # Index each subject individually
    self.subject.each do |s|
      already_indexed = []
      unless s.subjectLabel.empty? || already_indexed.include?(s.subjectLabel.first)
        s.to_solr(solr_doc)
        already_indexed << s.subjectLabel.first
      end
    end
    # Index each creator individually
    self.creation.each do |c|
      c.to_solr(solr_doc)
    end
    # Index each license individually
    self.license.each do |l|
        l.to_solr(solr_doc)
    end
    # Index each publication individually
    self.publication.each do |p|
        p.to_solr(solr_doc)
    end
    # Index each funding individually
    self.funding.each do |f|
        f.to_solr(solr_doc)
    end
    solr_doc
  end

  #TODO: Add FAST authority list later
  #begin
  #  LocalAuthority.register_vocabulary(self, "subject", "lc_subjects")
  #  LocalAuthority.register_vocabulary(self, "language", "lexvo_languages")
  #  LocalAuthority.register_vocabulary(self, "tag", "lc_genres")
  #rescue
  #  puts "tables for vocabularies missing"
  #end
end

