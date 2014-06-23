require 'vocabulary/prov_vocabulary'
require 'vocabulary/frapo_vocabulary'

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

end

class QualifiedFundingAssociation
  include ActiveFedora::RdfObject
  attr_accessor :agent, :role, :name, :funds, :awards

  rdf_subject { |ds|
    if ds.pid.nil?
      RDF::URI.new
    else
      RDF::URI.new("info:fedora/" + ds.pid + "#fundingAssociation")
    end
    }
  rdf_type rdf_type PROV.Association
  map_predicates do |map|
    map.agent(:in => PROV)
    map.role(:to => "hadRole", :in => PROV)
    map.name(:to => "n", :in => RDF::VCARD)
    map.funds(:to => "isFundingAgencyFor", :in => FRAPO)
    map.awards(:to => "awards", :in => FRAPO, class_name:"FundingAward")
    map.sameAs(:in => RDF::OWL)
  end
  accepts_nested_attributes_for :awards
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

end
