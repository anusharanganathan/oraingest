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

end

