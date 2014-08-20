require 'vocabulary/ora'
require 'vocabulary/pro'

class TitularActivity
  include ActiveFedora::RdfObject
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  attr_accessor :wasAssociatedWith, :titular

  rdf_subject { |ds|
    if ds.pid.nil?
      RDF::URI.new
    else
      RDF::URI.new("info:fedora/" + ds.pid + "#titularActivity")
    end
    }
  #rdf_type rdf_type RDF::PROV.Activity
  map_predicates do |map|
    map.type(:in => RDF::DC)
    map.wasAssociatedWith(:in => RDF::PROV)
    map.titular(:to => "qualifiedAssociation", :in => RDF::PROV, class_name:"QualifiedTitularAssociation")
  end
  accepts_nested_attributes_for :titular

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end 

  def to_solr(solr_doc={})
    self.titular.each do |c|
      c.to_solr(solr_doc)
    end
    solr_doc
  end

end

class QualifiedTitularAssociation
  include ActiveFedora::RdfObject
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  attr_accessor :type, :agent, :role

  rdf_subject { |ds|
    if ds.pid.nil?
      RDF::URI.new
    else
      RDF::URI.new("info:fedora/" + ds.pid + "#titularAssociation")
    end
    }
  #rdf_type rdf_type RDF::PROV.Association
  map_predicates do |map|
    map.type(:in => RDF::DC)
    map.agent(:in => RDF::PROV, class_name:"TitularAssociation")
    map.role(:to => "hadRole", :in => RDF::PROV)
  end
  accepts_nested_attributes_for :agent

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end

  def to_solr(solr_doc={})
    solr_doc[Solrizer.solr_name("desc_metadata__titularRole", :symbol)] ||= []
    solr_doc[Solrizer.solr_name("desc_metadata__titularAgent", :displayable)] ||= []
    solr_doc[Solrizer.solr_name("desc_metadata__titularRole", :symbol)] << self.role.first
    # Indexes each titular individually
    self.agent.each do |a|
      a.to_solr(solr_doc)
      titularHash = { 'role' => self.role.first }
      titularHash['name'] = a.name.first
      titularHash['roleHeldBy'] = a.roleHeldBy.first
      if !a.affiliation.nil? && !a.affiliation.first.nil?
        titularHash['affiliationName'] = a.affiliation.first.name.first
        titularHash['affiliationSameAs'] = a.affiliation.first.sameAs.first
      end
      solr_doc[Solrizer.solr_name("desc_metadata__titularAgent", :displayable)] << titularHash.to_json
    end
    solr_doc
  end

end

class TitularAssociation
  include ActiveFedora::RdfObject
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  attr_accessor :type, :name, :email, :affiliation, :sameAs

  rdf_type rdf_type RDF::ORA.TitularAgent
  map_predicates do |map|
    map.name(:to => "n", :in => RDF::VCARD)
    map.affiliation(:in => RDF::ORA, class_name:"Affiliation")
    map.roleHeldBy(:to => 'isHeldBy', :in => RDF::PRO)
  end
  accepts_nested_attributes_for :affiliation

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end 

  def to_solr(solr_doc={})
    # Initialize fields as array
    solr_doc[Solrizer.solr_name("desc_metadata__titularName", :stored_searchable)] ||= []
    solr_doc[Solrizer.solr_name("desc_metadata__titularName", :facetable)] ||= []
    solr_doc[Solrizer.solr_name("desc_metadata__titularRoleHeldBy", :stored_searchable)] ||= []
    solr_doc[Solrizer.solr_name("desc_metadata__titularRoleHeldBy", :facetable)] ||= []
    solr_doc[Solrizer.solr_name("desc_metadata__titularAffiliation", :stored_searchable)] ||= []
    solr_doc[Solrizer.solr_name("desc_metadata__titularAffiliation", :facetable)] ||= []
    solr_doc[Solrizer.solr_name("desc_metadata__titularAffiliationUrl", :symbol)] ||= []
    # Append values
    solr_doc[Solrizer.solr_name("desc_metadata__titularName", :stored_searchable)] << self.name.first
    solr_doc[Solrizer.solr_name("desc_metadata__titularName", :facetable)] << self.name.first
    solr_doc[Solrizer.solr_name("desc_metadata__titularRoleHeldBy", :stored_searchable)] << self.roleHeldBy.first
    solr_doc[Solrizer.solr_name("desc_metadata__titularRoleHeldBy", :facetable)] << self.roleHeldBy.first
    if !self.affiliation.nil? && !self.affiliation.first.nil?
      solr_doc[Solrizer.solr_name("desc_metadata__titularAffiliation", :stored_searchable)] << self.affiliation.first.name.first
      solr_doc[Solrizer.solr_name("desc_metadata__titularAffiliation", :facetable)] << self.affiliation.first.name.first
      solr_doc[Solrizer.solr_name("desc_metadata__titularAffiliationUrl", :symbol)] << self.affiliation.first.sameAs.first
    end
    solr_doc
  end

end

class Affiliation
  include ActiveFedora::RdfObject
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  attr_accessor :name, :sameAs

  rdf_subject { |ds|
    if ds.pid.nil?
      RDF::URI.new
    else
      RDF::URI.new("info:fedora/" + ds.pid + "#Affiliation")
    end
    }
  rdf_type rdf_type RDF::VCARD.Organization
  map_predicates do |map|
    map.name(:to => "n", :in => RDF::VCARD)
    map.sameAs(:in => RDF::OWL)
  end

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end 

end
