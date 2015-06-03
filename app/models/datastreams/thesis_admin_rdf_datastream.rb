class ThesisAdminRdfDatastream < ActiveFedora::NtriplesRDFDatastream

  attr_accessor :dispensationFromConsultation, :thirdPartyCopyright

  map_predicates do |map|
    map.dispensationFromConsultation(:in => RDF::ORA)
    map.thirdPartyCopyright(:in => RDF::ORA)
  end

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def to_solr(solr_doc={})
    solr_doc
  end

end