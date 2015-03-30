require 'vocabulary/bibo'
require 'vocabulary/fabio'
require 'vocabulary/ora'

class PublicationActivity
  include ActiveFedora::RdfObject
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  attr_accessor :publicationStatus, :reviewStatus, :hasDocument, :datePublished, :location, :dateAccepted, :wasAssociatedWith, :publisher

  rdf_subject { |ds|
    if ds.pid.nil?
      RDF::URI.new
    else
      RDF::URI.new("info:fedora/" + ds.pid + "#publicationActivity")
    end
    }
  #rdf_type rdf_type RDF::PROV.Activity
  map_predicates do |map|
    map.type(:in => RDF::DC)
    map.publicationStatus(:to => "DocumentStatus", :in => RDF::BIBO)
    map.reviewStatus(:in => RDF::ORA)
    map.hasDocument(:to => "generated", :in => RDF::PROV, class_name:"PublicationDocument")
    map.datePublished(:to => "generatedAtTime", :in => RDF::PROV)
    map.location(:to => "atLocation", :in => RDF::PROV)
    map.dateAccepted(:in => RDF::DC)
    map.wasAssociatedWith(:in => RDF::PROV)
    map.publisher(:to => "qualifiedAssociation", :in => RDF::PROV, class_name:"QualifiedPublicationAssociation")
  end
  accepts_nested_attributes_for :hasDocument
  accepts_nested_attributes_for :publisher

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end 

  def to_solr(solr_doc={})
    if !self.datePublished.nil? && !self.datePublished.first.nil?
      begin
        solr_doc[Solrizer.solr_name("desc_metadata__datePublished", :dateable, type: :date)] = Time.parse(self.datePublished.first).utc.iso8601
      rescue ArgumentError
        # Not a valid date.  Don't put it into the solr doc, or solr will choke.
      end
    end
    if !self.dateAccepted.nil? && !self.dateAccepted.first.nil?
      begin
        solr_doc[Solrizer.solr_name("desc_metadata__dateAccepted", :dateable, type: :date)] = Time.parse(self.dateAccepted.first).utc.iso8601
      rescue ArgumentError
        # Not a valid date.  Don't put it into the solr doc, or solr will choke.
      end
    end
    solr_doc[Solrizer.solr_name("desc_metadata__datePublished", :stored_searchable)] = self.datePublished.first
    solr_doc[Solrizer.solr_name("desc_metadata__location", :symbol)] = self.location.first
    solr_doc[Solrizer.solr_name("desc_metadata__dateAccepted", :stored_searchable)] = self.dateAccepted.first
    # Index publication document information
    if !self.hasDocument.nil? && !self.hasDocument.first.nil?
      self.hasDocument.first.to_solr(solr_doc)
    end
    # Index publisher information
    if !self.publisher.nil? && !self.publisher.first.nil?
      self.publisher.first.to_solr(solr_doc)
    end
    solr_doc
  end

end

class PublicationDocument
  include ActiveFedora::RdfObject
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  attr_accessor :identifier, :doi, :journal, :series, :uri

  rdf_subject { |ds|
    if ds.pid.nil?
      RDF::URI.new
    else
      RDF::URI.new("info:fedora/" + ds.pid + "#publicationDocument")
    end
    }
  rdf_type rdf_type RDF::FABIO.Work
  map_predicates do |map|
    map.identifier(:in => RDF::BIBO)
    map.doi(:in => RDF::BIBO)
    map.journal(:to => 'isPartOf', :in => RDF::DC, class_name:"PublicationJournal")
    map.series(:to => 'isPartOfSeries', :in => RDF::ORA, class_name:"PublicationSeries")
    map.uri(:in => RDF::BIBO)
  end
  accepts_nested_attributes_for :journal
  accepts_nested_attributes_for :series

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end 

  def to_solr(solr_doc={})
    solr_doc[Solrizer.solr_name("desc_metadata__publicationIdentifier", :symbol)] ||= []
    if self.identifier.kind_of?(Array)
      self.identifier.each do |i|
        solr_doc[Solrizer.solr_name("desc_metadata__publicationIdentifier", :symbol)] << i
      end
    else
      solr_doc[Solrizer.solr_name("desc_metadata__publicationIdentifier", :symbol)] << self.identifier
    end
    solr_doc[Solrizer.solr_name("desc_metadata__doi", :symbol)] = self.doi.first
    solr_doc[Solrizer.solr_name("desc_metadata__publicationUri", :displayable)] = self.uri.first
    if !self.series.nil? && !self.series.first.nil?
      solr_doc[Solrizer.solr_name("desc_metadata__seriesTitle", :stored_searchable)] = self.series.first.title.first
    end
    # Index journal information 
    if !self.journal.nil? && !self.journal.first.nil?
      self.journal.first.to_solr(solr_doc)
    end
    solr_doc
  end

end

class PublicationJournal
  include ActiveFedora::RdfObject
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  attr_accessor :title, :issn, :eissn, :volume, :issue, :pages

  rdf_subject { |ds|
    if ds.pid.nil?
      RDF::URI.new
    else
      RDF::URI.new("info:fedora/" + ds.pid + "#publicationJournal")
    end
    }
  rdf_type rdf_type RDF::BIBO.Journal
  map_predicates do |map|
    map.title(:in => RDF::DC)
    map.issn(:in => RDF::BIBO)
    map.eissn(:in => RDF::BIBO)
    map.volume(:in => RDF::BIBO)
    map.issue(:in => RDF::BIBO)
    map.pages(:in => RDF::BIBO)
  end

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end 

  def to_solr(solr_doc={})
    solr_doc[Solrizer.solr_name("desc_metadata__journalTitle", :stored_searchable)] = self.title.first
    solr_doc[Solrizer.solr_name("desc_metadata__issn", :symbol)] = self.issn.first
    solr_doc[Solrizer.solr_name("desc_metadata__eissn", :symbol)] = self.eissn.first
    solr_doc[Solrizer.solr_name("desc_metadata__volume", :displayable)] = self.volume.first
    solr_doc[Solrizer.solr_name("desc_metadata__issue", :displayable)] = self.issue.first
    solr_doc[Solrizer.solr_name("desc_metadata__pages", :displayable)] = self.pages.first
    solr_doc
  end

end

class PublicationSeries
  include ActiveFedora::RdfObject
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  attr_accessor :title

  rdf_subject { |ds|
    if ds.pid.nil?
      RDF::URI.new
    else
      RDF::URI.new("info:fedora/" + ds.pid + "#publicationSeries")
    end
    }
  rdf_type rdf_type RDF::BIBO.Series
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
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  attr_accessor :type, :agent, :role

  rdf_subject { |ds|
    if ds.pid.nil?
      RDF::URI.new
    else
      RDF::URI.new("info:fedora/" + ds.pid + "#publicationAssociation")
    end
    }
  #rdf_type rdf_type RDF::PROV.Association
  map_predicates do |map|
    map.type(:in => RDF::DC)
    map.agent(:in => RDF::PROV, class_name:"PublicationAssociation")
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
    self.agent.each do |a|
      a.to_solr(solr_doc)
    end
    solr_doc
  end

end

class PublicationAssociation
  include ActiveFedora::RdfObject
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  attr_accessor :type, :name, :website

  #rdf_type rdf_type RDF::PROV.Association
  map_predicates do |map|
    map.type(:in => RDF::DC)
    map.name(:to => "n", :in => RDF::VCARD)
    map.website(:to => "hasURL", :in => RDF::VCARD)
  end

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end 

  def to_solr(solr_doc={})
    # Initialize fields as array
    solr_doc[Solrizer.solr_name("desc_metadata__publisher", :stored_searchable)] ||= []
    solr_doc[Solrizer.solr_name("desc_metadata__publisherWebsite", :displayable)] ||= []
    # Append values
    solr_doc[Solrizer.solr_name("desc_metadata__publisher", :stored_searchable)] << self.name.first
    solr_doc[Solrizer.solr_name("desc_metadata__publisherWebsite", :displayable)] << self.website.first
    solr_doc
  end

end
