require 'rdf'
#require 'datastreams/person_rdf_datastream'
require 'vocabulary/bibo_vocabulary'
require 'vocabulary/camelot_vocabulary'
require 'vocabulary/dams_vocabulary'


class ArticleRdfDatastream < ActiveFedora::NtriplesRDFDatastream
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
    #TODO: Need to include nested attributes and QA lookup for subject - one to many
    #map.subject(:in => RDF::DC) do |index|
    #  index.as :stored_searchable, :facetable
    #end
    #-- keyword --
    #TODO - one to many
    map.keyword(:in => CAMELOT) do |index|
      index.as :stored_searchable, :facetable
    end
    #-- type --
    #TODO - needs to be a drop down list or auto complete
    map.type(:in => RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end
    #-- broader type --
    #TODO - needs to be a drop down list or auto complete
    map.broader_type(:to => "broader", :in => RDF::SKOS) do |index|
      index.as :stored_searchable, :facetable
    end
    #-- material --
    #map.material(:to => "PhysicalMedium", :in => RDF::DC) do |index|
    #  index.type :text
    #  index.as :stored_searchable
    #end
    #-- medium --
    map.medium(:in => RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end
    #-- language --
    #TODO: Need to include nested attributes and QA lookup for language
    #map.language(:in => RDF::DC) do |index|
    #  index.as :stored_searchable, :facetable
    #end
    #-- edition --
    map.edition(:in => BIBO) do |index|
      index.as :stored_searchable
    end
    #-- identifier --
    #TODO: Need to include nested attributes and matching for type - one to many
    #map.identifier(:in => RDF::DC) do |index|
    #  index.as :stored_searchable
    #end
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

  #TODO: Add FAST authority list later
  #begin
  #  LocalAuthority.register_vocabulary(self, "subject", "lc_subjects")
  #  LocalAuthority.register_vocabulary(self, "language", "lexvo_languages")
  #  LocalAuthority.register_vocabulary(self, "tag", "lc_genres")
  #rescue
  #  puts "tables for vocabularies missing"
  #end
end
