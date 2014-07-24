#require 'active_support/concern'
require 'rdf'
require 'vocabulary/ora'
require 'vocabulary/time'

class RelationsRdfDatastream < ActiveFedora::NtriplesRDFDatastream

  attr_accessor :hasPart, :accessRights, :influence, :qualifiedRelation

  map_predicates do |map|
    # For internal relations
    map.hasPart(:in => RDF::DC, class_name:"InternalRelations")
    map.accessRights(:in => RDF::DC, class_name:"EmbargoInfo")
    # For external relations
    map.influence(:to => "wasInfluencedBy", :in => RDF::PROV)
    map.qualifiedRelation(:to => "qualifiedInfluence", :in => RDF::PROV, class_name:"ExternalRelationsQualified")
  end
  accepts_nested_attributes_for :hasPart, :accessRights, :qualifiedRelation

  def getInfluences
    # Not Working
    influence = []
    self.qualifiedRelation.each do |qr|
      if !qr.entity.nil?
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
      "Closed access"
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
      if hp.identifier.first.start_with?('content') && !hp.accessRights.nil?
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

  rdf_type rdf_type RDF::PROV.Influence
  map_predicates do |map|
    #-- qualifying entity --
    map.entity(:to => "entity", :in => RDF::PROV, class_name:"ExternalRelations")
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
    riHash['url'] = self.entity.first.rdf_subject.to_s
    riHash['title'] = self.entity.first.title.first 
    riHash['description'] = self.entity.first.description.first
    riHash['citation'] = self.entity.first.citation.first
    riHash['typeOfRelation'] = self.relation.first
    solr_doc[Solrizer.solr_name("relations_metadata__relatedItem", :displayable)] << riHash.to_json
    solr_doc[Solrizer.solr_name("relations_metadata__relatedItemURL", :stored_searchable)] << self.entity.first.rdf_subject.to_s
    solr_doc[Solrizer.solr_name("relations_metadata__relatedItemRelation", :symbol)] << self.relation.first
    solr_doc
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
    map.embargoStatus(:in => RDF::ORA)
    #-- embargoStart --
    map.embargoStart(:in => RDF::ORA)
    #-- embargoEnd --
    map.embargoEnd(:in => RDF::ORA)
    #-- embargoReason --
    map.embargoReason(:in => RDF::ORA)
    #-- embargoRelease --
    map.embargoRelease(:in => RDF::ORA)
  end

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
    embargoHash['embargoStart'] = self.embargoStart.first 
    embargoHash['embargoEnd'] = self.embargoEnd.first 
    embargoHash['embargoReason'] = self.embargoReason.first 
    embargoHash['embargoRelease'] = self.embargoRelease.first 
    solr_doc[Solrizer.solr_name("relations_metadata__embargoInfo", :displayable)] << embargoHash.to_json
    if self.embargoEnd.first
      solr_doc[Solrizer.solr_name("relations_metadata__embargoDates", :stored_searchable)] << self.embargoEnd.first
      begin
        solr_doc[Solrizer.solr_name("relations_metadata__embargoDates", :dateable, type: :date)] << Time.parse(self.embargoEnd.first).utc.iso8601
      rescue ArgumentError
        # Not a valid date.  Don't put it into the solr doc, or solr will choke.
      end
    end
    solr_doc
  end

end

