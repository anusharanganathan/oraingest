require 'rdf'

class Location
  include ActiveFedora::RdfObject
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  attr_accessor :value

  rdf_type RDF::DC.Location
  map_predicates do |map|
    map.value(:in => RDF)
  end

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end

end

