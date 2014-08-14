require 'rdf'
require 'vocabulary/time'

class DateDuration
  include ActiveFedora::RdfObject
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  attr_accessor :start, :end

  map_predicates do |map|
    #-- type
    map.type(:in => RDF)
    #-- Start --
    map.start(:to => "hasBeginning", :in => RDF::TIME)
    #-- End --
    map.end(:to => "hasEnd", :in => RDF::TIME)
  end

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end

end

