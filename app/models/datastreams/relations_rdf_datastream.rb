#require 'active_support/concern'
require 'rdf'
require 'vocabulary/ora_vocabulary'

class RelationsRdfDatastream < ActiveFedora::NtriplesRDFDatastream

  attr_accessor :hasPart, :relation

  map_predicates do |map|
    # For internal relations
    map.hasPart(:in => RDF::DC, class_name:"InternalRelations")
    # For external relations
    map.relationship(:to =>"relation", :in => RDF::DC, class_name:"ExternalRelations")
  end
  accepts_nested_attributes_for :hasPart, :relation

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def embargoStatus
    articleVisible = true
    contentVisible = false
    hasContent = false
    self.hasPart.each do |hp|
      if hp.identifier.first == 'descMetadata'
        if hp.embargoStatus.first != 'Visible'
          articleVisible = false
        end
      elsif hp.identifier.first.start_with?('content')
        hasContent = true
        if hp.embargoStatus.first == 'Visible'
          contentVisible = true
        end
      end
    end
    if articleVisible
      if hasContent
        if contentVisible
          "Open access"
        else
          "Under embargo"
        end
      else
        "Reference record"
      end
    else
      "Closed"
    end
  end

  def embargoLevel
    if self.embargoStatus == "Open access"
      "success"
    elsif self.embargoStatus == "Under embargo"
      "info"
    elsif self.embargoStatus == "Reference record"
      "warning"
    else
      "error"
    end
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
    #-- identifier --
    map.identifier(:to=>"identifier", :in => RDF::DC)
    #-- title --
    map.title(:to=>"title", :in => RDF::DC)
    #-- description --
    map.description(:to=>"description", :in => RDF::DC)
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

