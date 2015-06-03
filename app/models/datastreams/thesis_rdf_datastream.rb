require 'vocabulary/camelot'
require 'vocabulary/ora'
require 'vocabulary/dams'

require 'fields/mads_language'
require 'fields/mads_subject'
require 'fields/work_type'
require 'fields/rights_activity'
require 'fields/creation_activity'
require 'fields/publication_activity'

class ThesisRdfDatastream < ActiveFedora::NtriplesRDFDatastream

  attr_accessor :title, :subtitle, :abstract, :subject, :keyword, :worktype, :medium, :language, :dateCopyrighted, :creation, :publication

  rdf_type rdf_type RDF::PROV.Entity
  map_predicates do |map|
    map.title(:in => RDF::DC)
    map.subtitle(:in => RDF::DAMS)
    map.abstract(:in => RDF::DC)
    map.subject(:in => RDF::DC, class_name:"MadsSubject")
    map.keyword(:in => RDF::CAMELOT)
    map.worktype(:to=>"type", :in => RDF::DC, class_name:"WorkType")

    map.medium(:in => RDF::DC)
    map.language(:in => RDF::DC, class_name:"MadsLanguage")

    map.dateCopyrighted(:in => RDF::DC)
    map.creation(:to => "hadCreationActivity", :in => RDF::ORA, class_name:"CreationActivity")

    map.publication(:to => "hadPublicationActivity", :in => RDF::ORA, class_name:"PublicationActivity")

    map.degreeName(:in => RDF::ORA)
    map.degreeType(:in => RDF::ORA)
    map.awardingBody(:in => RDF::ORA)
    map.dateOfAward(:in => RDF::ORA)
    map.examinerRole(:in => RDF::ORA)
    map.examinerAffiliation(:in => RDF::ORA)
    map.supervisor(:in => RDF::ORA)
  end

  accepts_nested_attributes_for :language
  accepts_nested_attributes_for :subject
  accepts_nested_attributes_for :worktype
  accepts_nested_attributes_for :creation
  accepts_nested_attributes_for :publication

  def to_solr(solr_doc={})
    solr_doc[Solrizer.solr_name("desc_metadata__title", :stored_searchable)] = self.title
    solr_doc[Solrizer.solr_name("desc_metadata__subtitle", :stored_searchable)] = self.subtitle
    solr_doc[Solrizer.solr_name("desc_metadata__abstract", :stored_searchable)] = self.abstract
    solr_doc[Solrizer.solr_name("desc_metadata__keyword", :stored_searchable)] = self.keyword
    solr_doc[Solrizer.solr_name("desc_metadata__medium", :stored_searchable)] = self.medium
    # solr_doc[Solrizer.solr_name("desc_metadata__publicationStatus", :stored_searchable)] = self.publicationStatus
    # solr_doc[Solrizer.solr_name("desc_metadata__reviewStatus", :stored_searchable)] = self.reviewStatus
    solr_doc[Solrizer.solr_name("desc_metadata__dateCopyrighted", :stored_searchable)] = self.dateCopyrighted
    # solr_doc[Solrizer.solr_name("desc_metadata__rightsHolder", :stored_searchable)] = self.rightsHolder
    # solr_doc[Solrizer.solr_name("desc_metadata__rightsHolderGroup", :stored_searchable)] = self.rightsHolderGroup

    # Index the type of work
    self.worktype.each do |w|
      already_indexed = []
      unless w.typeLabel.empty? || already_indexed.include?(w.typeLabel.first)
        w.to_solr(solr_doc)
        already_indexed << w.typeLabel.first
      end
    end
    # Index each language individually
    self.language.each do |l|
      already_indexed = []
      unless l.languageLabel.empty? || already_indexed.include?(l.languageLabel.first)
        l.to_solr(solr_doc)
        already_indexed << l.languageLabel.first
      end
    end
    # Index each subject individually
    self.subject.each do |s|
      already_indexed = []
      unless s.subjectLabel.empty? || already_indexed.include?(s.subjectLabel.first)
        s.to_solr(solr_doc)
        already_indexed << s.subjectLabel.first
      end
    end
    # Index each creator individually
    self.creation.each do |c|
      c.to_solr(solr_doc)
    end
    # Index each license individually
    # self.license.each do |l|
    #   l.to_solr(solr_doc)
    # end
    # Index each publication individually
    self.publication.each do |p|
      p.to_solr(solr_doc)
    end
    # Index each funding individually
    # self.funding.each do |f|
    #   f.to_solr(solr_doc)
    # end
    solr_doc
  end
end