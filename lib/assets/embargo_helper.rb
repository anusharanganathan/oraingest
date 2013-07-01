require 'rdf'
include RDF

def addEmbargo(filename, pid, dsid, embargoed, embargoedUntil, comment)
    uri = RDF::URI.new("info:fedora/"+pid+"/"+dsid)
    oxds = RDF::Vocabulary.new("http://vocab.ox.ac.uk/dataset/schema#")
    prefixes = {
      :rdf => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
      :oxds => "http://vocab.ox.ac.uk/dataset/schema#",
      :rdfs => "http://www.w3.org/2000/01/rdf-schema#"
    }
    graph = RDF::Graph.new
    if File.exists?(filename)
        RDF::RDFXML::Reader.open(filename) do |reader|
            reader.each_statement do |statement|
                 graph.insert(statement)
            end
        end
    end
    graph.delete([uri, nil, nil])
    graph.insert([uri, oxds.embargoed, RDF::Literal.new(embargoed)])
    graph.insert([uri, oxds.embargoedUntil, RDF::Literal.new(embargoedUntil)])
    graph.insert([uri, RDF::RDFS.comment, RDF::Literal.new(comment)])

    RDF::RDFXML::Writer.open(filename, :prefixes=>prefixes) do |writer|
      writer << graph
    end
end
