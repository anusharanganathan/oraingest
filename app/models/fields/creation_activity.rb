require 'vocabulary/prov_vocabulary'
require 'vocabulary/ora_vocabulary'

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
  #rdf_type rdf_type PROV.Activity
  map_predicates do |map|
    map.type(:in => RDF::DC)
    map.wasAssociatedWith(:in => PROV)
    map.creator(:to => "qualifiedAssociation", :in => PROV, class_name:"QualifiedCreationAssociation")
  end
  accepts_nested_attributes_for :creator

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
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
  #rdf_type rdf_type PROV.Association
  map_predicates do |map|
    map.type(:in => RDF::DC)
    map.agent(:in => PROV, class_name:"CreationAssociation")
    map.role(:to => "hadRole", :in => PROV)
  end
  accepts_nested_attributes_for :agent

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end 

end

class CreationAssociation
  include ActiveFedora::RdfObject
  attr_accessor :type, :name, :email, :affiliation, :sameAs

  #rdf_type rdf_type PROV.Association
  map_predicates do |map|
    map.type(:in => RDF::DC)
    map.name(:to => "n", :in => RDF::VCARD)
    map.email(:to => "hasEmail", :in => RDF::VCARD)
    map.affiliation(:in => ORA, class_name:"Affiliation")
    map.sameAs(:in => RDF::OWL)
  end
  accepts_nested_attributes_for :affiliation

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
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
