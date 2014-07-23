require 'vocabulary/rdfs_vocabulary'
require 'vocabulary/prov_vocabulary'

class LicenseStatement
  include ActiveFedora::RdfObject
  attr_accessor :licenseLabel, :licenseStatement, :licenseURI

  rdf_subject { |ds|
    if ds.pid.nil?
      RDF::URI.new
    else
      RDF::URI.new("info:fedora/" + ds.pid + "#license")
    end
    }
  map_predicates do |map|
    map.licenseLabel(:to => "label", :in => RDFS)
    map.licenseStatement(:to => "value", :in => RDFS)
    map.licenseURI(:to => "isDefinedBy", :in => RDFS)
  end

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end 

  def to_solr(solr_doc={})
    if !licenseLabel.first.empty?
      solr_doc[Solrizer.solr_name("desc_metadata__license", :stored_searchable)] = licenseLabel.first
    elsif !licenseURI.first.empty?
      solr_doc[Solrizer.solr_name("desc_metadata__license", :stored_searchable)] = licenseURI.first
    end
    solr_doc
  end

  #def attributes=(values)
  #  super(values)
  #end

end

class RightsStatement
  include ActiveFedora::RdfObject
  attr_accessor :rightsStatement, :rightsType

  rdf_subject { |ds|
    if ds.pid.nil?
      RDF::URI.new
    else
      RDF::URI.new("info:fedora/" + ds.pid + "#rights")
    end
    }
  map_predicates do |map|
    map.rightsStatement(:to => "value", :in => RDFS)
    map.rightsType(:to => "type", :in => RDF::DC)
  end

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end 

  #def attributes=(values)
  #  super(values)
  #end

end

class RightsActivity
  include ActiveFedora::RdfObject
  attr_accessor :activityType, :activityUsed, :activityGenerated

  rdf_subject { |ds|
    if ds.pid.nil?
      RDF::URI.new
    else
      RDF::URI.new("info:fedora/" + ds.pid + "#license")
    end
    }
  map_predicates do |map|
    map.activityType(:to => "type", :in => RDF::DC)
    map.activityUsed(:to => "used", :in => PROV)
    map.activityGenerated(:to => "generated", :in => PROV)
  end

  def persisted?
    rdf_subject.kind_of? RDF::URI
  end

  def id
    rdf_subject if rdf_subject.kind_of? RDF::URI
  end 

  #def attributes=(values)
  #  super(values)
  #end

end
