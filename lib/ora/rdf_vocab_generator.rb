#Source: http://www.snip2code.com/Snippet/27866/Use-RDF-rb-to-generate-an--RDF--Vocabula
require 'linkeddata'
require 'rdf/cli/vocab-loader'

vocab_sources = {
  mads: {
    prefix: "http://www.loc.gov/mads/rdf/v1#",
    source: "http://www.loc.gov/standards/mads/rdf/v1.rdf",
    strict: true
  },
  time: {
    prefix: "http://www.w3.org/2006/time#",
    source: "http://www.w3.org/2006/time",
    strict: true
  },
  bibo: {
    prefix: "http://purl.org/ontology/bibo/",
    source: "http://bibliontology.com/bibo/bibo.php#",
    strict: true
  },
}
 
vocab_sources.each do |id, v|
  begin
    out = StringIO.new
    loader = RDF::VocabularyLoader.new(id.to_s.upcase)
    loader.uri = v[:prefix]
    loader.source = v[:source] if v[:source]
    loader.extra = v[:extra] if v[:extra]
    loader.strict = v.fetch(:strict, true)
    loader.output = out
    loader.run
    out.rewind
    File.open("./#{id}.rb", "w") {|f| f.write out.read}
  rescue
    puts "Failed to load #{id}: #{$!.message}"
  end
end
