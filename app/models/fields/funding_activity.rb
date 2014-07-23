require 'vocabulary/prov_vocabulary'
require 'vocabulary/frapo_vocabulary'
require 'vocabulary/ora_vocabulary'

class FundingActivity
  include ActiveFedora::RdfObject
  attr_accessor :wasAssociatedWith, :funder

  rdf_subject { |ds|
    if ds.pid.nil?
      RDF::URI.new
    else
      RDF::URI.new("info:fedora/" + ds.pid + "#fundingActivity")
    end
    }
  rdf_type rdf_type PROV.Activity
  map_predicates do |map|
    map.wasAssociatedWith(:in => PROV)
    map.funder(:to => "qualifiedAssociation", :in => PROV, class_name:"QualifiedFundingAssociation")
  end
  accepts_nested_attributes_for :funder

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end 

  def to_solr(solr_doc={})
    self.funder.each do |f|
      f.to_solr(solr_doc)
    end
    solr_doc
  end

end

class QualifiedFundingAssociation
  include ActiveFedora::RdfObject
  attr_accessor :agent, :role, :funds, :awards, :annotates

  rdf_subject { |ds|
    if ds.pid.nil?
      RDF::URI.new
    else
      RDF::URI.new("info:fedora/" + ds.pid + "#fundingAssociation")
    end
    }
  rdf_type rdf_type PROV.Association
  map_predicates do |map|
    map.agent(:in => PROV, class_name:"FundingAssociation")
    map.role(:to => "hadRole", :in => PROV)
    map.funds(:to => "isFundingAgencyFor", :in => FRAPO)
    map.awards(:to => "awards", :in => FRAPO, class_name:"FundingAward")
    map.annotation(:in => ORA)
  end
  accepts_nested_attributes_for :awards, :agent
  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end 

  def to_solr(solr_doc={})
    solr_doc[Solrizer.solr_name("desc_metadata__funder", :stored_searchable)] ||= []
    solr_doc[Solrizer.solr_name("desc_metadata__funder", :facetable)] ||= []
    solr_doc[Solrizer.solr_name("desc_metadata__funderSameAs", :symbol)] ||= []
    solr_doc[Solrizer.solr_name("desc_metadata__funderRole", :symbol)] ||= []
    solr_doc[Solrizer.solr_name("desc_metadata__funderFunds", :stored_searchable)] ||= []
    solr_doc[Solrizer.solr_name("desc_metadata__funderAnnotation", :displayable)] ||= []

    solr_doc[Solrizer.solr_name("desc_metadata__funder", :stored_searchable)] << self.agent.first.name.first
    solr_doc[Solrizer.solr_name("desc_metadata__funder", :facetable)] << self.agent.first.name.first
    solr_doc[Solrizer.solr_name("desc_metadata__funderSameAs", :symbol)] << self.agent.first.sameAs.first
    solr_doc[Solrizer.solr_name("desc_metadata__funderRole", :symbol)] << self.role.first
    solr_doc[Solrizer.solr_name("desc_metadata__funderAnnotation", :displayable)] << self.annotation.first
    # Index each entity funded
    if self.funds.kind_of?(Array)
      self.funds.each do |f|
        solr_doc[Solrizer.solr_name("desc_metadata__funderFunds", :stored_searchable)] << f
      end
    else
        solr_doc[Solrizer.solr_name("desc_metadata__funderFunds", :stored_searchable)] << self.funds
    end
    # Index each award
    self.awards.each do |a|
      a.to_solr(solr_doc)
    end
    solr_doc
  end

end

class FundingAssociation
  include ActiveFedora::RdfObject
  attr_accessor :type, :name, :sameAs

  map_predicates do |map|
    map.type(:in => RDF::DC)
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

class FundingAward
  include ActiveFedora::RdfObject
  attr_accessor :grantNumber

  rdf_subject { |ds|
    if ds.pid.nil?
      RDF::URI.new
    else
      RDF::URI.new("info:fedora/" + ds.pid + "#fundingAward")
    end
    }
  rdf_type rdf_type FRAPO.Grant
  map_predicates do |map|
    map.grantNumber(:to => "hasGrantNumber", :in => FRAPO)
  end

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end 

  def to_solr(solr_doc={})
    solr_doc[Solrizer.solr_name("desc_metadata__funderGrantNumber", :stored_searchable)] ||= []
    if self.grantNumber.kind_of?(Array)
      self.grantNumber.each do |gn|
        solr_doc[Solrizer.solr_name("desc_metadata__funderGrantNumber", :stored_searchable)] << gn
      end
    else
        solr_doc[Solrizer.solr_name("desc_metadata__funderGrantNumber", :stored_searchable)] << self.grantNumber
    end
    solr_doc
  end

end
