# -*- encoding : utf-8 -*-
class SolrDocument 
  # Adds Sufia behaviors to the SolrDocument.
  include Sufia::SolrDocumentBehavior

  include Blacklight::Solr::Document

  # self.unique_key = 'id'

  def subtitle
    Array(self[Solrizer.solr_name('desc_metadata__subtitle')]).first
  end

  def medium
    Array(self[Solrizer.solr_name('desc_metadata__medium')]).first
  end
  
  def numPages
    Array(self[Solrizer.solr_name('desc_metadata__numPages')]).first
  end
  
  def publicationStatus
    Array(self[Solrizer.solr_name('desc_metadata__publicationStatus')]).first
  end
 
  def reviewStatus
    Array(self[Solrizer.solr_name('desc_metadata__reviewStatus')]).first
  end
 
  def submission_workflow_status 
    get(Solrizer.solr_name("MediatedSubmission_status", :symbol))
  end
  
  def submission_workflow_date_submitted
    get(Solrizer.solr_name("MediatedSubmission_date_submitted", :dateable))
  end
  
  def submission_workflow_current_reviewer_id
    get(Solrizer.solr_name("MediatedSubmission_current_reviewer_id", :symbol))
  end
  
  # The following shows how to setup this blacklight document to display marc documents
  extension_parameters[:marc_source_field] = :marc_display
  extension_parameters[:marc_format_type] = :marcxml
  use_extension( Blacklight::Solr::Document::Marc) do |document|
    document.key?( :marc_display  )
  end
  
  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension( Blacklight::Solr::Document::Email )
  
  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension( Blacklight::Solr::Document::Sms )

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics
  # and Blacklight::Solr::Document#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension( Blacklight::Solr::Document::DublinCore)    
  field_semantics.merge!(    
                         :title => "title_display",
                         :author => "author_display",
                         :language => "language_facet",
                         :format => "format"
                         )
end
