require 'vocabulary/ora'

class CreationActivity
  include ActiveFedora::RdfObject
  attr_accessor :wasAssociatedWith, :creator

  rdf_subject { |ds|
    if ds.pid.nil?
      RDF::URI.new
    else
      RDF::URI.new("info:fedora/" + ds.pid + "#creationActivity")
    end
    }
  #rdf_type rdf_type RDF::PROV.Activity
  map_predicates do |map|
    map.type(:in => RDF::DC)
    map.wasAssociatedWith(:in => RDF::PROV)
    map.creator(:to => "qualifiedAssociation", :in => RDF::PROV, class_name:"QualifiedCreationAssociation")
  end
  accepts_nested_attributes_for :creator

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end 

  def to_solr(solr_doc={})
    self.creator.each do |c|
      c.to_solr(solr_doc)
    end
    solr_doc
  end

end

class QualifiedCreationAssociation
  include ActiveFedora::RdfObject
  attr_accessor :type, :agent, :role

  rdf_subject { |ds|
    if ds.pid.nil?
      RDF::URI.new
    else
      RDF::URI.new("info:fedora/" + ds.pid + "#creationAssociation")
    end
    }
  #rdf_type rdf_type RDF::PROV.Association
  map_predicates do |map|
    map.type(:in => RDF::DC)
    map.agent(:in => RDF::PROV, class_name:"CreationAssociation")
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
    solr_doc[Solrizer.solr_name("desc_metadata__creatorRole", :symbol)] ||= []
    solr_doc[Solrizer.solr_name("desc_metadata__creator", :displayable)] ||= []
    solr_doc[Solrizer.solr_name("desc_metadata__creatorRole", :symbol)] << self.role.first
    # Indexes each creator individually
    self.agent.each do |a|
      a.to_solr(solr_doc)
      creatorHash = { 'role' => self.role.first }
      creatorHash['name'] = a.name.first
      creatorHash['email'] = a.email.first
      creatorHash['sameAs'] = a.sameAs.first
      creatorHash['affiliationName'] = a.affiliation.first.name.first
      creatorHash['affiliationSameAs'] = a.affiliation.first.sameAs.first
      solr_doc[Solrizer.solr_name("desc_metadata__creator", :displayable)] << creatorHash.to_json
    end
    solr_doc
  end

end

class CreationAssociation
  include ActiveFedora::RdfObject
  attr_accessor :type, :name, :email, :affiliation, :sameAs

  #rdf_type rdf_type RDF::PROV.Association
  map_predicates do |map|
    map.type(:in => RDF::DC)
    map.name(:to => "n", :in => RDF::VCARD)
    map.email(:to => "hasEmail", :in => RDF::VCARD)
    map.affiliation(:in => RDF::ORA, class_name:"Affiliation")
    map.sameAs(:in => RDF::OWL)
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
    solr_doc[Solrizer.solr_name("desc_metadata__creatorName", :stored_searchable)] ||= []
    solr_doc[Solrizer.solr_name("desc_metadata__creatorName", :facetable)] ||= []
    solr_doc[Solrizer.solr_name("desc_metadata__creatorEmail", :displayable)] ||= []
    solr_doc[Solrizer.solr_name("desc_metadata__creatorSameAs", :stored_searchable)] ||= []
    solr_doc[Solrizer.solr_name("desc_metadata__creatorSameAs", :facetable)] ||= []
    solr_doc[Solrizer.solr_name("desc_metadata__creatorAffiliation", :stored_searchable)] ||= []
    solr_doc[Solrizer.solr_name("desc_metadata__creatorAffiliation", :facetable)] ||= []
    solr_doc[Solrizer.solr_name("desc_metadata__creatorAffiliationUrl", :symbol)] ||= []
    # Append values
    solr_doc[Solrizer.solr_name("desc_metadata__creatorName", :stored_searchable)] << self.name.first
    solr_doc[Solrizer.solr_name("desc_metadata__creatorName", :facetable)] << self.name.first
    solr_doc[Solrizer.solr_name("desc_metadata__creatorEmail", :displayable)] << self.email.first
    solr_doc[Solrizer.solr_name("desc_metadata__creatorSameAs", :stored_searchable)] << self.sameAs.first
    solr_doc[Solrizer.solr_name("desc_metadata__creatorSameAs", :facetable)] << self.sameAs.first
    solr_doc[Solrizer.solr_name("desc_metadata__creatorAffiliation", :stored_searchable)] << self.affiliation.first.name.first
    solr_doc[Solrizer.solr_name("desc_metadata__creatorAffiliation", :facetable)] << self.affiliation.first.name.first
    solr_doc[Solrizer.solr_name("desc_metadata__creatorAffiliationUrl", :symbol)] << self.affiliation.first.sameAs.first
    solr_doc
  end

end

class Affiliation
  include ActiveFedora::RdfObject
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
