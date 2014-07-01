#require 'active_support/concern'
require 'rdf'
#require 'datastreams/person_rdf_datastream'
#Vocabularies
require 'vocabulary/bibo_vocabulary'
require 'vocabulary/camelot_vocabulary'
require 'vocabulary/ora_vocabulary'
require 'vocabulary/dams_vocabulary'
require 'vocabulary/mads_vocabulary'
require 'vocabulary/prov_vocabulary'
require 'vocabulary/prov_vocabulary'
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

  attr_accessor :title, :subtitle, :description, :abstract, :keyword, :worktype, :medium, :language, :language_attributes, :numPages, :pages, :publicationStatus, :reviewStatus, :subject, :license, :dateCopyrighted, :rightsHolder, :rights, :rightsActivity, :creation, :funding, :publication

  #rdf_subject { |ds|
  #  if ds.identifier
  #    RDF::URI.new("info:fedora/" + ds.identifier)
  #  end
  #  }
  rdf_type rdf_type PROV.Entity
  map_predicates do |map|
    #-- title --
    map.title(:in => RDF::DC) do |index|
      index.as :stored_searchable
    end
    #-- subtitle --
    map.subtitle(:in => DAMS) do |index|
      index.as :stored_searchable
    end
    #-- description --
    map.description(:in => RDF::DC) do |index|
      index.type :text
      index.as :stored_searchable
    end
    #-- abstract --
    map.abstract(:in => RDF::DC) do |index|
      index.type :text
      index.as :stored_searchable
    end
    #-- subject --
    #TODO: Need to include QA lookup for subject
    map.subject(:in => RDF::DC, class_name:"MadsSubject")
    #-- keyword --
    map.keyword(:in => CAMELOT) do |index|
      index.as :stored_searchable, :facetable
    end
    #-- type --
    map.worktype(:to=>"type", :in => RDF::DC, class_name:"WorkType")
    #-- medium --
    map.medium(:in => RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end
    #-- language --
    #TODO: Need to include QA lookup for language
    map.language(:in => RDF::DC, class_name:"MadsLanguage")
    #-- edition --
    map.edition(:in => BIBO) do |index|
      index.as :stored_searchable
    end
    #-- numPages --    
    map.numPages(:in => BIBO) do |index|
      index.as :stored_searchable
    end
    #-- page numbers --
    map.pages(:in => BIBO) do |index|
      index.as :stored_searchable
    end    
    #-- note --
    # TODO: Nested attributes of value and label - one to many
    #-- source --
    # TODO: Nested attributes of name, homepage and uri - one to many
    # -- publication status --
    map.publicationStatus(:to => "DocumentStatus", :in => BIBO) do |index|
      index.as :stored_searchable, :facetable
    end
    # -- review status --
    # TODO: Drop down list of values
    map.reviewStatus(:in => ORA) do |index|
      index.as :stored_searchable, :facetable
    end
    # -- rights activity --
    map.license(:in => RDF::DC, class_name:"LicenseStatement")
    map.dateCopyrighted(:in => RDF::DC) do |index|
      index.as :stored_searchable
    end
    map.rightsHolder(:in => RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end
    map.rightsHolderGroup(:in => ORA) do |index|
      index.as :stored_searchable, :facetable
    end
    map.rights(:in => RDF::DC, class_name:"RightsStatement")
    map.rightsActivity(:in => PROV, :to => "hadActivity", class_name:"RightsActivity")
    # -- creation activity --
    # TODO: Lookup CUD and link with Fedora person objects
    map.creation(:to => "hadCreationActivity", :in => ORA, class_name:"CreationActivity")
    # -- funding activity --
    # TODO: Lookup and link with Fedora funder objects
    map.funding(:to => "isOutputOf", :in => FRAPO, class_name:"FundingActivity")
    #-- publication activity --
    map.publication(:to => "hadPublicationActivity", :in => ORA, class_name:"PublicationActivity")
    # -- Commissioning body --
    # TODO: Nested attributes using Prov

  end
  accepts_nested_attributes_for :language, :subject, :worktype, :license, :rights, :rightsActivity, :creation, :funding, :publication

  #TODO: Add FAST authority list later
  #begin
  #  LocalAuthority.register_vocabulary(self, "subject", "lc_subjects")
  #  LocalAuthority.register_vocabulary(self, "language", "lexvo_languages")
  #  LocalAuthority.register_vocabulary(self, "tag", "lc_genres")
  #rescue
  #  puts "tables for vocabularies missing"
  #end
end

