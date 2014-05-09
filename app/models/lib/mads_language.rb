class MadsLanguage
  #  <mads:authoritativeLabel>French</mads:authoritativeLabel>
  #  <mads:code>fre</mads:code>
  #  <mads:hasExactExternalAuthority rdf:resource="http://id.loc.gov/vocabulary/iso639-2/fre.html"/>
  #  <mads:isMemberOfMADSScheme rdf:resource="http://id.loc.gov/vocabulary/iso639-2.html" />
  require 'vocabulary/mads_vocabulary'
  include ActiveFedora::RdfObject
  rdf_type rdf_type MADS.Language
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
end