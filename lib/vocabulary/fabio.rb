module RDF
  class FABIO < RDF::Vocabulary("http://purl.org/spar/fabio/")
    property :hasEmbargoDate
    property :hasEmbargoDuration
    property :Work
    property :isStoredOn
    property :AnalogStorageMedium
    property :DigitalStorageMedium
  end
end
