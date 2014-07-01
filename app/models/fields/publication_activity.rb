require 'vocabulary/prov_vocabulary'
require 'vocabulary/ora_vocabulary'

class PublicationActivity
  include ActiveFedora::RdfObject
  attr_accessor :generated, :datePublished, :location, :dateAccepted, :wasAssociatedWith, :publisher

  rdf_subject { |ds|
    if ds.pid.nil?
      RDF::URI.new
    else
      RDF::URI.new("info:fedora/" + ds.pid + "#publicationActivity")
    end
    }
  #rdf_type rdf_type PROV.Activity
  map_predicates do |map|
    map.type(:in => RDF::DC)
    map.hasDocument(:to => "generated", :in => PROV, class_name:"PublicationDocument")
    map.datePublished(:to => "generatedAtTime", :in => PROV)
    map.location(:to => "atLocation", :in => PROV)
    map.dateAccepted(:in => RDF::DC)
    map.wasAssociatedWith(:in => PROV)
    map.publisher(:to => "qualifiedAssociation", :in => PROV, class_name:"QualifiedPublicationAssociation")
  end
  accepts_nested_attributes_for :hasDocument, :publisher

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end 

end

class PublicationDocument
  include ActiveFedora::RdfObject
  attr_accessor :identifier, :doi, :journal, :uri

  rdf_subject { |ds|
    if ds.pid.nil?
      RDF::URI.new
    else
      RDF::URI.new("info:fedora/" + ds.pid + "#publicationDocument")
    end
    }
  rdf_type rdf_type BIBO.Document
  map_predicates do |map|
    map.identifier(:in => BIBO)
    map.doi(:in => BIBO)
    map.journal(:to => 'isPartOf', :in => RDF::DC, class_name:"PublicationJournal")
    map.uri(:in => BIBO)
  end
  accepts_nested_attributes_for :journal

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end 

end

class PublicationJournal
  include ActiveFedora::RdfObject
  attr_accessor :title, :issn, :eissn, :periodical, :volume, :issue, :pages

  rdf_subject { |ds|
    if ds.pid.nil?
      RDF::URI.new
    else
      RDF::URI.new("info:fedora/" + ds.pid + "#publicationJournal")
    end
    }
  rdf_type rdf_type BIBO.Journal
  map_predicates do |map|
    map.title(:in => RDF::DC)
    map.issn(:in => BIBO)
    map.eissn(:in => BIBO)
    map.periodical(:to => 'isPartOf', :in => RDF::DC, class_name:"PublicationPeriodical")
    map.volume(:in => BIBO)
    map.issue(:in => BIBO)
    map.pages(:in => BIBO)
  end
  accepts_nested_attributes_for :periodical

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end 

end

class PublicationPeriodical
  include ActiveFedora::RdfObject
  attr_accessor :title

  rdf_subject { |ds|
    if ds.pid.nil?
      RDF::URI.new
    else
      RDF::URI.new("info:fedora/" + ds.pid + "#publicationPeriodcial")
    end
    }
  rdf_type rdf_type BIBO.Periodical
  map_predicates do |map|
    map.title(:in => RDF::DC)
  end

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end 

end

class QualifiedPublicationAssociation
  include ActiveFedora::RdfObject
  attr_accessor :type, :agent, :role, :name, :website

  rdf_subject { |ds|
    if ds.pid.nil?
      RDF::URI.new
    else
      RDF::URI.new("info:fedora/" + ds.pid + "#publicationAssociation")
    end
    }
  #rdf_type rdf_type PROV.Association
  map_predicates do |map|
    map.type(:in => RDF::DC)
    map.agent(:in => PROV)
    map.role(:to => "hadRole", :in => PROV)
    map.name(:to => "n", :in => RDF::VCARD)
    map.website(:to => "hasURL", :in => RDF::VCARD)
  end

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end 

end
