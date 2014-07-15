#require 'active_support/concern'
require 'rdf'
require 'vocabulary/ora_vocabulary'
require 'vocabulary/prov_vocabulary'

class RelationsRdfDatastream < ActiveFedora::NtriplesRDFDatastream

  attr_accessor :hasPart, :accessRights, :influence, :qualifiedRelation

  map_predicates do |map|
    # For internal relations
    map.hasPart(:in => RDF::DC, class_name:"InternalRelations")
    map.accessRights(:in => RDF::DC, class_name:"EmbargoInfo")
    # For external relations
    map.influence(:to => "wasInfluencedBy", :in => PROV)
    map.qualifiedRelation(:to => "qualifiedInfluence", :in => PROV, class_name:"ExternalRelationsQualified")
  end
  accepts_nested_attributes_for :hasPart, :qualifiedRelation

  def getInfluences
    # Not Working
    influence = []
    self.qualifiedRelation.each do |qr|
      if !qr.entity.empty?
         qr.entity.each do |qre|
           influence.push(qre.rdf_subject.to_s)
         end
      end
    end
    influence
  end

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def embargoStatus
    articleVisible = true
    contentVisible = false
    hasContent = false
    self.accessRights.each do |ar|
      if ar.embargoStatus.first != 'Visible'
        articleVisible = false
      end
    end
    self.hasPart.each do |hp|
      if hp.identifier.first.start_with?('content')
        hasContent = true
        hp.accessRights.each do |ar|
          if ar.embargoStatus.first == 'Visible'
            contentVisible = true
          end
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
  attr_accessor :identifier, :description, :type, :format, :accessRights

  map_predicates do |map|
    map.identifier(:in => RDF::DC)
    #-- description --
    map.description(:in => RDF::DC)
    #-- type --
    map.type(:to=>"type", :in => RDF::DC)
    #-- format --
    map.format(:in => RDF::DC)
    #-- embargo info --
    map.accessRights(:in => RDF::DC, class_name:"EmbargoInfo")
  end

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end

end

class ExternalRelationsQualified
  include ActiveFedora::RdfObject
  attr_accessor :relation, :entity

  rdf_type rdf_type PROV.Influence
  map_predicates do |map|
    #-- qualifying entity --
    map.entity(:to => "entity", :in => PROV, class_name:"ExternalRelations")
    #-- relation --
    map.relation(:to=>"relation", :in => RDF::DC)
  end
  accepts_nested_attributes_for :entity

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
    map.type(:in => RDF::DC)
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

class EmbargoInfo
  include ActiveFedora::RdfObject
  attr_accessor :embargoStatus, :embargoStart, :embargoEnd, :embargoReason, :embargoRelease

  map_predicates do |map|
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

