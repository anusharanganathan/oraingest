require 'vocabulary/rdfs_vocabulary'

class WorkType
  include ActiveFedora::RdfObject
  attr_accessor :typelabel, :typeAuthority

  #  <mads:authoritativeLabel>French</mads:authoritativeLabel>
  #  <mads:code>fre</mads:code>
  #  <mads:hasExactExternalAuthority rdf:resource="http://id.loc.gov/vocabulary/iso639-2/fre.html"/>
  #  <mads:isMemberOfMADSScheme rdf:resource="http://id.loc.gov/vocabulary/iso639-2.html" />
  rdf_subject { |ds|
    if ds.pid.nil?
      RDF::URI.new
    else
      RDF::URI.new("info:fedora/" + ds.pid + "#type")
    end
    }
  map_predicates do |map|
    map.typeLabel(:to => "label", :in => RDFS)
    map.typeAuthority(:to => "type", :in => RDF)
  end

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end 

  def to_solr(solr_doc={})
    super
    solr_doc[Solrizer.solr_name("desc_metadata__type", :stored_searchable)] = typeLabel.first
    solr_doc[Solrizer.solr_name("desc_metadata__typeAuthority", :stored_searchable)] = typeAuthority.first
    solr_doc
  end

  #def attributes=(values)
  #  super(values)
  #end

end
