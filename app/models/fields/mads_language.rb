require 'vocabulary/mads_vocabulary'
class MadsLanguage
  include ActiveFedora::RdfObject
  #include ModelHelper
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
    map.languageLabel(:to => "authoritativeLabel", :in => MADS)
    map.languageCode(:to => "code", :in => MADS)
    map.languageAuthority(:to => "hasExactExternalAuthority", :in => MADS)
    map.languageScheme(:to => "isMemberOfMADSScheme", :in => MADS)
  end

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end 

  def to_solr(solr_doc={})
    super
    solr_doc[Solrizer.solr_name("desc_metadata__language", :stored_searchable)] = languageLabel.first
    solr_doc[Solrizer.solr_name("desc_metadata__languageCode", :stored_searchable)] = languageCode.first
    solr_doc[Solrizer.solr_name("desc_metadata__languageAuthority", :stored_searchable)] = languageAuthority.first
    solr_doc[Solrizer.solr_name("desc_metadata__languageAcheme", :stored_searchable)] = languageScheme.first
    solr_doc
  end

  #def attributes=(values)
  #  super(values)
  #end

end
