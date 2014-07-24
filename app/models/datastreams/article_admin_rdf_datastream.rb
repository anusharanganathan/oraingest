#require 'active_support/concern'
require 'rdf'
require 'vocabulary/ora'

class ArticleAdminRdfDatastream < ActiveFedora::NtriplesRDFDatastream

  attr_accessor :oaStatus, :apcPaid, :oaReason, :refException

  map_predicates do |map|
    # For internal relations
    map.oaStatus(:in => RDF::ORA)
    map.apcPaid(:in => RDF::ORA)
    map.oaReason(:in => RDF::ORA)
    map.refException(:in => RDF::ORA)
  end

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def to_solr(solr_doc={})
    super
    solr_doc[Solrizer.solr_name("admin_metadata__oaStatus", :symbol)] = self.oaStatus
    solr_doc[Solrizer.solr_name("admin_metadata__apcPaid", :symbol)] = self.apcPaid
    solr_doc[Solrizer.solr_name("admin_metadata__oaReason", :symbol)] = self.oaReason
    solr_doc[Solrizer.solr_name("admin_metadata__refException", :stored_searchable)] = self.refException
    solr_doc
  end

end

