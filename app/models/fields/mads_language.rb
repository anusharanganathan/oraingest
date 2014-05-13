require 'vocabulary/mads_vocabulary'
class MadsLanguage
  include ActiveFedora::RdfObject
  include ModelHelper
  attr_accessor :languageLabel, :languageCode, :languageAuthority, :languageScheme
  #  <mads:authoritativeLabel>French</mads:authoritativeLabel>
  #  <mads:code>fre</mads:code>
  #  <mads:hasExactExternalAuthority rdf:resource="http://id.loc.gov/vocabulary/iso639-2/fre.html"/>
  #  <mads:isMemberOfMADSScheme rdf:resource="http://id.loc.gov/vocabulary/iso639-2.html" />
  rdf_subject { |ds|
    if ds.pid.nil?
      RDF::URI.new
    else
      RDF::URI.new("http://ora.ox.ac.uk/objects/" + ds.pid + "#language")
    end
    }
  rdf_type MADS.Language
  map_predicates do |map|
    map.languageLabel(:to => "authoritativeLabel", :in => MADS) do |index|
      index.as :stored_searchable, :facetable
    end
    map.languageCode(:to => "code", :in => MADS) do |index|
      index.as :stored_searchable, :facetable
    end
    map.languageAuthority(:to => "hasExactExternalAuthority", :in => MADS) do |index|
      index.type :text
      index.as :stored_searchable
    end
    map.languageScheme(:to => "isMemberOfMADSScheme", :in => MADS) do |index|
      index.type :text
      index.as :stored_searchable
    end
  end

  def to_solr (solr_doc={})
    Solrizer.insert_field(solr_doc, 'language', languageLabel.first)
    Solrizer.insert_field(solr_doc, 'lnguageCode', languageCode.first)
    Solrizer.insert_field(solr_doc, "languageAuthority", languageAuthority.first)
    Solrizer.insert_field(solr_doc, "languageScheme", languageScheme.first)
    solr_base solr_doc
  end

end
