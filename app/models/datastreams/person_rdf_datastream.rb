require "oxford_terms"

class PersonRdfDatastream < ActiveFedora::NtriplesRDFDatastream
  #include ActiveFedora::RdfObject
  rdf_type rdf_type RDF::FOAF.Person
  map_predicates do |map|
    map.identifier(:in => RDF::DC)
    map.first_name(:to => "givenName", :in => RDF::FOAF)
    map.last_name(:to => "lastName", :in => RDF::FOAF)
    map.display_name(:to => "displayName", :in => OxfordTerms)
    map.title(:in => RDF::FOAF)
    map.email(:to => "mbox", :in => RDF::FOAF)
    map.website(:to => "homepage", :in => RDF::FOAF)
    map.institution(:in => OxfordTerms)
    map.faculty(:in => OxfordTerms)
    map.oxford_college(:to => "oxfordCollege", :in => OxfordTerms)
    map.research_group(:to => "researchGroup", :in => OxfordTerms)
    map.webauth(:in => OxfordTerms)
  end

  def email_address
    return self.email
  end

  def name
    if self.display_name && !self.display_name.empty?
      return self.display_name
    elsif self.last_name && !self.last_name.empty? and self.first_name && !self.first_name.empty?
      return self.first_name.zip(self.last_name).map {|a| a.inject {|sum, x| (sum + " " + x rescue sum)}}
    elsif self.last_name && !self.last_name.empty?
      return self.last_name
    elsif self.first_name && !self.first_name.empty?
      return self.first_name
    else
      return self.webauth
    end
    #return self.display_name.titleize || self.first_name + " " + self.last_name || self.webauth rescue self.webauth
  end
end 
