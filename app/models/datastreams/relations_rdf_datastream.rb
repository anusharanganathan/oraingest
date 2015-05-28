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

  def datastream_has_access_rights?(dsid)
    status = false
    self.hasPart.each do |hp|
      if hp.identifier[0] == dsid
        if hp.accessRights && hp.accessRights[0].has_access_rights?
          status = true
        end
      end
    end
    status
  end
 
  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def embargoStatus
    # 3 embargo states: Open access, Closed access, Access restricted until embargo end date 
    articleVisible = true
    contentVisible = false
    hasContent = false
    unless self.accessRights.any? && self.accessRights.first.has_access_rights? && self.accessRights.first.embargoStatus.first == 'Open access'
      articleVisible = false
    end
    self.hasPart.each do |hp|
      if hp.identifier.first.start_with?('content')
        hasContent = true
        if hp.accessRights.any? && hp.accessRights.first.has_access_rights? && hp.accessRights.first.embargoStatus.first == 'Open access'
          contentVisible = true
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
    if self.accessRights.any? && self.accessRights.first.has_access_rights?
      self.accessRights.first.to_solr(solr_doc)
    end
    self.hasPart.each do |hp|
      if hp.identifier.first.start_with?('content') && hp.accessRights.first.has_access_rights?
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
    if self.entity.any?
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
    #-- identifier - to record ids given which aren't URIs -- 
    map.identifier(:in => RDF::DC)
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

  def has_access_rights?
    status = false
    unless self.embargoStatus.first.blank?
      status = true
    end
    status
  end

  def embargoInfo
    embargoHash = {}
    embargoHash['identifier'] = rdf_subject.to_s
    unless self.embargoStatus.first.blank?
      embargoHash['embargoStatus'] = self.embargoStatus.first
    end
    if self.embargoReason.any?
      embargoHash['embargoReason'] = self.embargoReason
    end
    unless self.embargoRelease.first.blank?
      embargoHash['embargoRelease'] = self.embargoRelease.first
    end

    if self.embargoDate.first
      # Embargo end - type, date and human
      if self.embargoDate.first.end.first
        unless self.embargoDate.first.end.first.label.first.blank?
          embargoHash['embargoEndType'] = self.embargoDate.first.end.first.label.first
        end
        unless self.embargoDate.first.end.first.date.blank?
          embargoHash['embargoEnd'] = self.embargoDate.first.end.first.date.first
        end
        if embargoHash.has_key?('embargoEndType') && embargoHash.has_key?('embargoEnd')
          case embargoHash['embargoEndType']
          when "Stated", "Defined"
            embargoHash['embargoEndHuman'] = "until #{embargoHash['embargoEnd']}"
          when "Approximate"
            embargoHash['embargoEndHuman'] = "after #{embargoHash['embargoEnd']}"
          end
        end
      end
      # Embargo start - type and date
      if self.embargoDate.first.start.first
        unless self.embargoDate.first.start.first.label.first.blank?
          embargoHash['embargoStartType'] = self.embargoDate.first.start.first.label.first
        end
        unless self.embargoDate.first.start.first.date.first.blank?
          embargoHash['embargoStart'] = self.embargoDate.first.start.first.date.first
        end
      end
      # Embargo duration
      if self.embargoDate.first.duration.first
        if (self.embargoDate.first.duration.first.years.first.to_i > 0) || (self.embargoDate.first.duration.first.months.first.to_i > 0)
          embargoHash['embargoDuration'] = "%d years and %d months"% [self.embargoDate.first.duration.first.years.first.to_i, self.embargoDate.first.duration.first.months.first.to_i]
        end
      end
      # Embargo duration - human
      if embargoHash.has_key?('embargoDuration') && embargoHash.has_key?('embargoStartType')
        if embargoHash['embargoStartType'] == "Date" && embargoHash.has_key?('embargoStart')
          if embargoHash['embargoStart'] == Time.now
            embargoHash['embargoDurationHuman'] = "#{embargoHash['embargoDuration']} from today"
          else
            embargoHash['embargoDurationHuman'] = "#{embargoHash['embargoDuration']} from #{embargoHash['embargoStart']}"
          end
        elsif embargoHash['embargoStartType'] == "Publication date"
          if embargoHash.has_key?('embargoStart') && embargoHash.has_key?('embargoEndType') && embargoHash['embargoEndType'] == "Defined"
            # If embargoEndType = Approximate, than we do not know the publication date and have set it tp today
            embargoHash['embargoDurationHuman'] = "#{embargoHash['embargoDuration']} from publication date (#{embargoHash['embargoStart']})"
          else
            embargoHash['embargoDurationHuman'] = "#{embargoHash['embargoDuration']} from publication date"
          end
        end
      end

    end #embargo date not nil
    embargoHash
  end 

  def to_solr(solr_doc={})
    solr_doc[Solrizer.solr_name("relations_metadata__embargoInfo", :displayable)] ||= []
    solr_doc[Solrizer.solr_name("relations_metadata__embargoDates", :dateable, type: :date)] ||= []
    solr_doc[Solrizer.solr_name("relations_metadata__embargoDates", :stored_searchable)] ||= []
    if self.embargoInfo.has_key?("embargoEnd")
      solr_doc[Solrizer.solr_name("relations_metadata__embargoDates", :stored_searchable)] << self.embargoInfo["embargoEnd"]
      begin 
        solr_doc[Solrizer.solr_name("relations_metadata__embargoDates", :dateable, type: :date)] << Chronic.parse(self.embargoInfo["embargoEnd"]).utc.iso8601
      rescue
      end
    end
    solr_doc[Solrizer.solr_name("relations_metadata__embargoInfo", :displayable)] << self.embargoInfo.to_json
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
    #-- embargoDuration --
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
