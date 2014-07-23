#require 'active_support/concern'
require 'rdf'
require 'vocabulary/ora_vocabulary'

class ArticleAdminRdfDatastream < ActiveFedora::NtriplesRDFDatastream

  attr_accessor :oaStatus, :apcPaid, :oaReason, :refException

  map_predicates do |map|
    # For internal relations
    map.oaStatus(:in => ORA)
    map.apcPaid(:in => ORA)
    map.oaReason(:in => ORA)
    map.refException(:in => ORA)
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

