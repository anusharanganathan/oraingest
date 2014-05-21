#require 'active_support/concern'
require 'rdf'
#require 'datastreams/person_rdf_datastream'
require 'vocabulary/bibo_vocabulary'
require 'vocabulary/camelot_vocabulary'
require 'vocabulary/dams_vocabulary'
require 'vocabulary/mads_vocabulary'
require 'fields/mads_language'
require 'fields/mads_subject'
require 'fields/work_type'

class ArticleRdfDatastream < ActiveFedora::NtriplesRDFDatastream
  #include ModelHelper

  attr_accessor :title, :subtitle, :description, :abstract, :keyword, :worktype, :medium, :language, :language_attributes, :numPages, :pages, :publicationStatus, :reviewStatus, :subject, :subject_attributes

  #include MadsTopic
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
    #-- publication activity --
    # TODO: Nested attributes using Prov
    # -- publication status --
    # TODO: Drop down list of values
    map.publicationStatus(:in => CAMELOT) do |index|
      index.as :stored_searchable, :facetable
    end
    # -- review status --
    # TODO: Drop down list of values
    map.reviewStatus(:in => CAMELOT) do |index|
      index.as :stored_searchable, :facetable
    end
    # -- rights activity --
    # TODO: Nested attributes using Prov
    # -- creation activity --
    # TODO: Nested attributes using Prov, Lookup CUD, Fedora person objects and funder objects
    # -- funding activity --
    # TODO: Nested attributes using Prov, Lookup funder objects
    # -- thesis activity --
    # TODO: Nested attributes using Prov
    # -- Commissioning body --
    # TODO: Nested attributes using Prov

  end
  accepts_nested_attributes_for :language, :subject, :worktype

  #TODO: Add FAST authority list later
  #begin
  #  LocalAuthority.register_vocabulary(self, "subject", "lc_subjects")
  #  LocalAuthority.register_vocabulary(self, "language", "lexvo_languages")
  #  LocalAuthority.register_vocabulary(self, "tag", "lc_genres")
  #rescue
  #  puts "tables for vocabularies missing"
  #end
end

