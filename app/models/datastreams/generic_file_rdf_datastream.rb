require 'rdf'
require 'datastreams/person_rdf_datastream'
require 'oxford_terms'

class GenericFileRdfDatastream < ActiveFedora::NtriplesRDFDatastream
  map_predicates do |map|
    map.part_of(:to => "isPartOf", :in => RDF::DC)
    map.resource_type(:to => "type", :in => RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end
    map.title(:in => RDF::DC) do |index|
      index.as :stored_searchable
    end
    map.subtitle(:in => OxfordTerms) do |index|
      index.as :stored_searchable
    end
    map.creator(:in => RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end
    map.rights_ownership(:to=> "rightsOwnership", :in => OxfordTerms) do |index|
      index.as :stored_searchable
    end
    map.third_party_copyright(:to=> "hasThirdPartyCopyright", :in => OxfordTerms) do |index|
      index.as :stored_searchable
    end
    map.description(:in => RDF::DC) do |index|
      index.type :text
      index.as :stored_searchable
    end
    map.abstract(:in => RDF::DC) do |index|
      index.type :text
      index.as :stored_searchable
    end
    map.subject(:in => RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end
    map.keyword(:in => OxfordTerms) do |index|
      index.as :stored_searchable, :facetable
    end
    map.language(:in => RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end
    map.doi(:in => OxfordTerms) do |index|
      index.as :stored_searchable
    end
    map.local_id(:to => "localIdentifier", :in => OxfordTerms) do |index|
      index.as :stored_searchable
    end
    map.issn(:in => OxfordTerms) do |index|
      index.as :stored_searchable
    end
    map.isbn(:in => OxfordTerms) do |index|
      index.as :stored_searchable
    end
    map.eissn(:in => OxfordTerms) do |index|
      index.as :stored_searchable
    end
    map.uuid(:in => OxfordTerms) do |index|
      index.as :stored_searchable
    end
    map.identifier(:in => RDF::DC) do |index|
      index.as :stored_searchable
    end
    map.grant_number(:to => "grantNumber", :in => OxfordTerms) do |index|
      index.as :stored_searchable
    end
    map.edition(:in => OxfordTerms) do |index|
      index.as :stored_searchable
    end
    map.status(:in => OxfordTerms) do |index|
      index.as :stored_searchable
    end
    map.version(:in => OxfordTerms) do |index|
      index.as :stored_searchable
    end
    map.journal(:in => OxfordTerms) do |index|
      index.as :stored_searchable
    end
    map.volume(:in => OxfordTerms) do |index|
      index.as :stored_searchable
    end
    map.issue(:in => OxfordTerms) do |index|
      index.as :stored_searchable
    end
    map.pages(:in => OxfordTerms) do |index|
      index.as :stored_searchable
    end
    map.tag(:to => "relation", :in => RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end
    map.rights(:in => RDF::DC) do |index|
      index.as :stored_searchable
    end
    map.date_created(:to => "created", :in => RDF::DC) do |index|
      index.as :stored_searchable
    end
    map.date_uploaded(:to => "dateSubmitted", :in => RDF::DC) do |index|
      index.type :date
      index.as :stored_sortable
    end
    map.date_modified(:to => "modified", :in => RDF::DC) do |index|
      index.type :date
      index.as :stored_sortable
    end
    map.identifier(:in => RDF::DC) do |index|
      index.as :stored_searchable
    end
    map.based_near(:in => RDF::FOAF) do |index|
      index.as :stored_searchable, :facetable
    end
    map.related_url(:to => "seeAlso", :in => RDF::RDFS)


    # Not including people/organisations in descMetadata
    #map.contributor(:in => RDF::DC)
    #map.author(:in => OxfordTerms)
    #map.editor(:in => OxfordTerms)
    #map.copyright_holder(:to=> "copyrightHolder", :in => OxfordTerms)
    #map.authors(to: :author, :in => OxfordTerms, class_name:"PersonRdfDatastream")
    #map.editors(to: :editor, :in => OxfordTerms, class_name:"PersonRdfDatastream")
    #map.contributors(to: :contributor, :in => RDF::DC, class_name:"PersonRdfDatastream")
    #map.copyright_holders(:to=> "copyrightHolder", :in => OxfordTerms, class_name:"PersonRdfDatastream")
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
