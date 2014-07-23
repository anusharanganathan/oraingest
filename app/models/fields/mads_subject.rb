require 'vocabulary/mads_vocabulary'
class MadsSubject
  include ActiveFedora::RdfObject
  attr_accessor :subjectLabel, :subjectAuthority, :subjectScheme

  #  <mads:authoritativeLabel>French</mads:authoritativeLabel>
  #  <mads:code>fre</mads:code>
  #  <mads:hasExactExternalAuthority rdf:resource="http://id.loc.gov/vocabulary/iso639-2/fre.html"/>
  #  <mads:isMemberOfMADSScheme rdf:resource="http://id.loc.gov/vocabulary/iso639-2.html" />
  rdf_subject { |ds|
    if ds.pid.nil?
      RDF::URI.new
    else
      RDF::URI.new("info:fedora/" + ds.pid + "#subject1")
    end
    }
  map_predicates do |map|
    map.subjectLabel(:to => "authoritativeLabel", :in => MADS)
    map.subjectAuthority(:to => "hasExactExternalAuthority", :in => MADS)
    map.subjectScheme(:to => "isMemberOfMADSScheme", :in => MADS)
  end

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end 

  def to_solr(solr_doc={})
    #Initialize as array
    solr_doc[Solrizer.solr_name("desc_metadata__subject", :stored_searchable)] ||= []
    solr_doc[Solrizer.solr_name("desc_metadata__subject", :facetable)] ||= [] 
    solr_doc[Solrizer.solr_name("desc_metadata__subjectAuthority", :stored_searchable)] ||= []
    solr_doc[Solrizer.solr_name("desc_metadata__subjectScheme", :stored_searchable)] ||= []
    # Index
    solr_doc[Solrizer.solr_name("desc_metadata__subject", :stored_searchable)] << subjectLabel.first
    solr_doc[Solrizer.solr_name("desc_metadata__subject", :facetable)] << subjectLabel.first
    solr_doc[Solrizer.solr_name("desc_metadata__subjectAuthority", :stored_searchable)] << subjectAuthority.first
    solr_doc[Solrizer.solr_name("desc_metadata__subjectScheme", :stored_searchable)] << subjectScheme.first
    solr_doc
  end

  #def attributes=(values)
  #  super(values)
  #end

end
