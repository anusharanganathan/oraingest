require 'vocabulary/mads'
class MadsLanguage
  include ActiveFedora::RdfObject
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  attr_accessor :languageLabel, :languageCode, :languageAuthority, :languageScheme

  #  <mads:authoritativeLabel>French</mads:authoritativeLabel>
  #  <mads:code>fre</mads:code>
  #  <mads:hasExactExternalAuthority rdf:resource="http://id.loc.gov/vocabulary/iso639-2/fre.html"/>
  #  <mads:isMemberOfMADSScheme rdf:resource="http://id.loc.gov/vocabulary/iso639-2.html" />
  rdf_subject { |ds|
    if ds.pid.nil?
      RDF::URI.new
    else
      RDF::URI.new("info:fedora/" + ds.pid + "#language")
    end
    }
  rdf_type RDF::MADS.Language
  map_predicates do |map|
    map.languageLabel(:to => "authoritativeLabel", :in => RDF::MADS)
    map.languageCode(:to => "code", :in => RDF::MADS)
    map.languageAuthority(:to => "hasExactExternalAuthority", :in => RDF::MADS)
    map.languageScheme(:to => "isMemberOfMADSScheme", :in => RDF::MADS)
  end

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end 

  def to_solr(solr_doc={})
    solr_doc[Solrizer.solr_name("desc_metadata__language", :stored_searchable)] = self.languageLabel.first
    solr_doc[Solrizer.solr_name("desc_metadata__languageCode", :stored_searchable)] = self.languageCode.first
    solr_doc[Solrizer.solr_name("desc_metadata__languageAuthority", :stored_searchable)] = self.languageAuthority.first
    solr_doc[Solrizer.solr_name("desc_metadata__languageScheme", :stored_searchable)] = self.languageScheme.first
    solr_doc
  end

  #def attributes=(values)
  #  super(values)
  #end

end
