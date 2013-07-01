class EmbargoAsset
  include ActiveFedora::RdfObject
  map_predicates do
    oxds = RDF::Vocabulary.new("http://vocab.ox.ac.uk/dataset/schema#")
    map.embargoedUntil(in: oxds)
    map.embargoed(in: oxds)
    map.comment(in: RDF::RDFS)
  end
end
