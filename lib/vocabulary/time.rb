module RDF
  class TIME < RDF::Vocabulary("http://www.w3.org/2006/time#")
    property :TemporalEntity
    property :hasBeginning
    property :DurationDescription
    property :hasDurationDescription
    property :years
    property :months
    property :weeks
    property :days
    property :hours
    property :minutes
    property :seconds
  end
end
