#require 'active_support/concern'
require 'rdf'
require 'chronic'
require 'vocabulary/ora'
require 'vocabulary/time'
require 'vocabulary/fabio'

class RelationsRdfDatastream < ActiveFedora::NtriplesRDFDatastream
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  attr_accessor :hasPart, :accessRights, :influence, :qualifiedRelation

  map_predicates do |map|
    # For internal relations
    map.hasPart(:in => RDF::DC, class_name: "InternalRelations")
    map.accessRights(:in => RDF::DC, class_name: "EmbargoInfo")
    # For external relations
    map.influence(:to => "wasInfluencedBy", :in => RDF::PROV)
    map.qualifiedRelation(:to => "qualifiedInfluence", :in => RDF::PROV, class_name: "ExternalRelationsQualified")
  end
  accepts_nested_attributes_for :hasPart
  accepts_nested_attributes_for :accessRights
  accepts_nested_attributes_for :qualifiedRelation

  def getInfluences
    # Not Working
    influence = []
    self.qualifiedRelation.each do |qr|
      qr.entity.each do |qre|
        influence.push(qre.rdf_subject.to_s)
      end
    end
    influence
  end

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def embargoStatus
    # 3 embargo states: Open access, Closed access, Access restricted until embargo end date 
    articleVisible = true
    contentVisible = false
    hasContent = false
    if !self.accessRights.nil? && !self.accessRights.first.nil?
      if self.accessRights.first.embargoStatus != 'Open access'
        articleVisible = false
      end
    end
    self.hasPart.each do |hp|
      if !hp.nil?
        if hp.identifier.first.start_with?('content')
          hasContent = true
          if !hp.accessRights.nil? && !hp.accessRights.first.nil? && hp.accessRights.first.embargoStatus == 'Open access'
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
          "Embargoed"
        end
      else
        "Catalogued"
      end
    else
      "Closed access"
    end
  end

  def embargoClass
    if self.embargoStatus == "Open access"
      "success"
    elsif self.embargoStatus == "Embargoed"
      "info"
    elsif self.embargoStatus == "Catalogued"
      "warning"
    else
      "error"
    end
  end

  def to_solr(solr_doc={})
    super 
    # Index embargo info
    solr_doc[Solrizer.solr_name("relations_metadata__embargoStatus", :symbol)] = self.embargoStatus
    solr_doc[Solrizer.solr_name("relations_metadata__embargoDates", :dateable, type: :date)] ||= []
    solr_doc[Solrizer.solr_name("relations_metadata__embargoDates", :stored_searchable)] ||= []
    if !self.accessRights.nil? && !self.accessRights.first.nil?
      self.accessRights.first.to_solr(solr_doc)
    end
    self.hasPart.each do |hp|
      if !hp.nil? && hp.identifier.first.start_with?('content') && !hp.accessRights.nil? && !hp.accessRights.first.nil?
        hp.accessRights.first.to_solr(solr_doc)
      end #if content and accessRights
    end #each hasPart
    # index external relation
    self.qualifiedRelation.each do |qr|
      qr.to_solr(solr_doc)
    end
    solr_doc
  end

end

class InternalRelations
  include ActiveFedora::RdfObject
  extend ActiveModel::Naming
  include ActiveModel::Conversion
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
    map.accessRights(:in => RDF::DC, class_name: "EmbargoInfo")
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
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  attr_accessor :relation, :entity

  rdf_type rdf_type RDF::PROV.Influence
  map_predicates do |map|
    #-- qualifying entity --
    map.entity(:to => "entity", :in => RDF::PROV, class_name: "ExternalRelations")
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

  def to_solr(solr_doc={})
    solr_doc[Solrizer.solr_name("relations_metadata__relatedItem", :displayable)] ||= []
    solr_doc[Solrizer.solr_name("relations_metadata__relatedItemURL", :stored_searchable)] ||= []
    solr_doc[Solrizer.solr_name("relations_metadata__relatedItemRelation", :symbol)] ||= []
    riHash = {}
    if !self.entity.nil? && !self.entity.first.nil?
      riHash['url'] = self.entity.first.rdf_subject.to_s
      riHash['title'] = self.entity.first.title.first 
      riHash['description'] = self.entity.first.description.first
      riHash['citation'] = self.entity.first.citation.first
      riHash['typeOfRelation'] = self.relation.first
      solr_doc[Solrizer.solr_name("relations_metadata__relatedItem", :displayable)] << riHash.to_json
      solr_doc[Solrizer.solr_name("relations_metadata__relatedItemURL", :stored_searchable)] << self.entity.first.rdf_subject.to_s
      solr_doc[Solrizer.solr_name("relations_metadata__relatedItemRelation", :symbol)] << self.relation.first
    end
    solr_doc
  end

end

class ExternalRelations
  include ActiveFedora::RdfObject
  extend ActiveModel::Naming
  include ActiveModel::Conversion
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
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  attr_accessor :embargoStatus, :embargoDate, :embargoReason, :embargoRelease

  rdf_type RDF::PSO.PublicationStatus
  map_predicates do |map|
    #-- embargoStatus --
    map.embargoStatus(:in => RDF::ORA)
    #-- embargoDate --
    map.embargoDate(:to => "hasEmbargoDuration", :in => RDF::FABIO, class_name: "EmbargoDate")
    #-- embargoReason --
    map.embargoReason(:in => RDF::ORA)
    #-- embargoRelease --
    map.embargoRelease(:in => RDF::ORA)
  end
  accepts_nested_attributes_for :embargoDate

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end

  def to_solr(solr_doc={})
    solr_doc[Solrizer.solr_name("relations_metadata__embargoInfo", :displayable)] ||= []
    solr_doc[Solrizer.solr_name("relations_metadata__embargoDates", :dateable, type: :date)] ||= []
    solr_doc[Solrizer.solr_name("relations_metadata__embargoDates", :stored_searchable)] ||= []
    embargoHash = {}
    embargoHash['identifier'] = rdf_subject.to_s
    embargoHash['embargoStatus'] = self.embargoStatus.first 
    embargoHash['embargoReason'] = self.embargoReason.first 
    embargoHash['embargoRelease'] = self.embargoRelease.first 

    if !self.embargoDate.nil? && !self.embargoDate.first.nil?
      if !self.embargoDate.first.end.nil? && !self.embargoDate.first.end.first.nil?
        if !self.embargoDate.first.end.first.label.nil? && !self.embargoDate.first.end.first.date.nil?
          embargoHash['embargoEnd'] = "%s %s"% [self.embargoDate.first.end.first.label.first, self.embargoDate.first.end.first.date.first]
        elsif !self.embargoDate.first.end.first.date.nil?
          embargoHash['embargoEnd'] = self.embargoDate.first.end.first.date.first
        end
        if !self.embargoDate.first.end.first.date.nil?
          solr_doc[Solrizer.solr_name("relations_metadata__embargoDates", :stored_searchable)] << self.embargoDate.first.end.first.date.first
          begin 
            solr_doc[Solrizer.solr_name("relations_metadata__embargoDates", :dateable, type: :date)] << Chronic.parse(self.embargoDate.first.end.first.date.first).utc.iso8601
          rescue
          end
        end
      end
      if !self.embargoDate.first.start.nil? && !self.embargoDate.first.start.first.nil?
        if !self.embargoDate.first.start.first.label.nil? && !self.embargoDate.first.start.first.date.nil?
          embargoHash['embargoStart'] = "%s %s"% [self.embargoDate.first.start.first.label.first, self.embargoDate.first.start.first.date.first]
        elsif !self.embargoDate.first.start.first.label.nil?
          embargoHash['embargoStart'] = self.embargoDate.first.start.first.label.first
        elsif !self.embargoDate.first.start.first.date.nil?
          embargoHash['embargoStart'] = self.embargoDate.first.start.first.date.first
        end
      end
      if !self.embargoDate.first.duration.nil? && !self.embargoDate.first.duration.first.nil? 
        embargoHash['embargoPeriod'] = "%d years and %d months"% [self.embargoDate.first.duration.first.years.first.to_i, self.embargoDate.first.duration.first.months.first.to_i]
      end
    end
    solr_doc[Solrizer.solr_name("relations_metadata__embargoInfo", :displayable)] << embargoHash.to_json
    solr_doc
  end

end

class EmbargoDate
  include ActiveFedora::RdfObject
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  attr_accessor :start, :end, :duration

  rdf_type RDF::TIME.TemporalEntity
  map_predicates do |map|
    #-- embargoStart --
    map.start(:to => "hasBeginning", :in => RDF::TIME, class_name: "LabelledDate")
    #-- embargoPeriod --
    map.duration(:to => "hasDurationDescription", :in => RDF::TIME, class_name: "EmbargoDuration")
    #-- embargoEnd --
    map.end(:to => "hasEnd", :in => RDF::TIME, class_name: "LabelledDate")
  end
  accepts_nested_attributes_for :start
  accepts_nested_attributes_for :duration
  accepts_nested_attributes_for :end

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end

end

class LabelledDate
  include ActiveFedora::RdfObject
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  attr_accessor :date, :label

  map_predicates do |map|
    #-- start date --
    map.date(:to=> 'value', :in => RDF)
    #-- start description --
    map.label(:in => RDF::RDFS)
  end

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end

end

class EmbargoDuration
  include ActiveFedora::RdfObject
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  attr_accessor :years, :months

  map_predicates do |map|
    #-- embargo duration - years --
    map.years(:in => RDF::TIME)
    #-- embargo duration - months --
    map.months(:in => RDF::TIME)
  end

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end

end
