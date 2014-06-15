#require 'active_support/concern'
require 'rdf'
require 'vocabulary/ora_vocabulary'

class RelationsRdfDatastream < ActiveFedora::NtriplesRDFDatastream

  attr_accessor :hasPart, :relation

  map_predicates do |map|
    # For internal relations
    map.hasPart(:in => RDF::DC, class_name:"InternalRelations")
    # For external relations
    map.relation(:in => RDF::DC, class_name:"ExternalRelations")
  end
  accepts_nested_attributes_for :hasPart, :relation

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

end

class InternalRelations
  include ActiveFedora::RdfObject
  attr_accessor :description, :type, :format, :embargoStatus, :embargoStart, :embargoEnd, :embargoReason, :embargoRelease

  map_predicates do |map|
    #-- identifier --
    map.identifier(:in => RDF::DC)
    #-- description --
    map.description(:in => RDF::DC)
    #-- type --
    map.type(:to=>"type", :in => RDF::DC)
    #-- format --
    map.format(:in => RDF::DC)
    #-- embargoStatus --
    map.embargoStatus(:in => ORA)
    #-- embargoStart --
    map.embargoStart(:in => ORA)
    #-- embargoEnd --
    map.embargoEnd(:in => ORA)
    #-- embargoReason --
    map.embargoReason(:in => ORA)
    #-- embargoRelease --
    map.embargoRelease(:in => ORA)
  end

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end

end

class ExternalRelations
  include ActiveFedora::RdfObject
  attr_accessor :title, :description, :type, :citation

  map_predicates do |map|
    #-- title --
    map.title(:in => RDF::DC)
    #-- description --
    map.description(:in => RDF::DC)
    #-- type --
    map.type(:to=>"type", :in => RDF::DC)
    #-- citation --
    map.citation(:to => "bibliographicCitation", :in => RDF::DC)
  end

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end

end

