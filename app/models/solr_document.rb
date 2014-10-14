# -*- encoding : utf-8 -*-
class SolrDocument 
  # Adds Sufia behaviors to the SolrDocument.
  include Sufia::SolrDocumentBehavior

  include Blacklight::Solr::Document

  # self.unique_key = 'id'

  def subtitle
    Array(self[Solrizer.solr_name('desc_metadata__subtitle', :stored_searchable)]).first
  end

  def abstract
    Array(self[Solrizer.solr_name('desc_metadata__abstract', :stored_searchable)]).first
  end

  def medium
    Array(self[Solrizer.solr_name('desc_metadata__medium', :stored_searchable)]).first
  end

  def keywords
    Array(self[Solrizer.solr_name("desc_metadata__keyword", :stored_searchable)])
  end
 
  def publicationStatus
    Array(self[Solrizer.solr_name('desc_metadata__publicationStatus', :stored_searchable)]).first
  end
 
  def reviewStatus
    Array(self[Solrizer.solr_name('desc_metadata__reviewStatus', :stored_searchable)]).first
  end

  def worktypeLabel
    Array(self[Solrizer.solr_name('desc_metadata__type', :stored_searchable)]).first
  end

  def worktypeAuthority
    Array(self[Solrizer.solr_name('desc_metadata__typeAuthority', :stored_searchable)]).first
  end

  def language
    Array(self[Solrizer.solr_name('desc_metadata__language', :stored_searchable)]).first
  end
 
  def languageCode
    Array(self[Solrizer.solr_name('desc_metadata__languageCode', :stored_searchable)]).first
  end
 
  def languageScheme
    Array(self[Solrizer.solr_name('desc_metadata__languageScheme', :stored_searchable)]).first
  end
 
  def languageAuthority
    Array(self[Solrizer.solr_name('desc_metadata__languageAuthority', :stored_searchable)]).first
  end
  
  def subject
    Array(self[Solrizer.solr_name('desc_metadata__subject', :stored_searchable)]).first
  end
 
  def subjectScheme
    Array(self[Solrizer.solr_name('desc_metadata__subjectScheme', :stored_searchable)]).first
  end
 
  def subjectAuthority
    Array(self[Solrizer.solr_name('desc_metadata__subjectAuthority', :stored_searchable)]).first
  end
  
  def creators
    ans = Array(self[Solrizer.solr_name('desc_metadata__creator', :displayable)])
    ans = ans.map{|a| JSON.parse(a) }
  end
 
  def license
    Array(self[Solrizer.solr_name('desc_metadata__license', :stored_searchable)]).first
  end
 
  def datePublished_s
    Array(self[Solrizer.solr_name('desc_metadata__datePublished', :stored_searchable)]).first
  end
 
  def datePublished
    Array(self[Solrizer.solr_name('desc_metadata__datePublished', :dateable, type: date)]).first
  end
 
  def dateAccepted_s
    Array(self[Solrizer.solr_name('desc_metadata__dateAccepted', :stored_searchable)]).first
  end
 
  def dateAccepted
    Array(self[Solrizer.solr_name('desc_metadata__dateAccepted', :dateable, type: date)]).first
  end
 
  def doi
    Array(self[Solrizer.solr_name('desc_metadata__doi', :symbol)]).first
  end

  def issn
    Array(self[Solrizer.solr_name('desc_metadata__issn', :symbol)]).first
  end

  def eissn
    Array(self[Solrizer.solr_name('desc_metadata__eissn', :symbol)]).first
  end

  def seriesTitle
    Array(self[Solrizer.solr_name('desc_metadata__seriesTitle', :stored_searchable)]).first
  end
 
  def journalTitle
    Array(self[Solrizer.solr_name('desc_metadata__journalTitle', :stored_searchable)]).first
  end
 
  def volume
    Array(self[Solrizer.solr_name('desc_metadata__volume', :displayable)]).first
  end
 
  def issue
    Array(self[Solrizer.solr_name('desc_metadata__issue', :displayable)]).first
  end
 
  def pages
    Array(self[Solrizer.solr_name('desc_metadata__pages', :displayable)]).first
  end
 
  def publisher
    Array(self[Solrizer.solr_name('desc_metadata__publisher', :stored_searchable)]).first
  end
 
  def publisherWebsite
    Array(self[Solrizer.solr_name('desc_metadata__publisherWebsite', :stored_searchable)]).first
  end
 
  def funder
    Array(self[Solrizer.solr_name('desc_metadata__funder', :stored_searchable)]).first
  end
 
  def oaStatus
    Array(self[Solrizer.solr_name('admin_metadata__oaStatus', :symbol)]).first
  end
 
  def apcPaid
    Array(self[Solrizer.solr_name('admin_metadata__apcPaid', :symbol)]).first
  end
 
  def oaReason
    Array(self[Solrizer.solr_name('admin_metadata__oaReason', :symbol)]).first
  end
 
  def documentation
    Array(self[Solrizer.solr_name('desc_metadata__documentation', :stored_searchable)]).first
  end
 
  def spatial
    Array(self[Solrizer.solr_name('desc_metadata__spatial', :stored_searchable)]).first
  end
 
  def locator
    Array(self[Solrizer.solr_name('desc_metadata__locator', :stored_searchable)]).first
  end
 
  def digitalSize 
    Array(self[Solrizer.solr_name('desc_metadata__digitalSize', :stored_searchable)]).first
  end
 
  def format
    Array(self[Solrizer.solr_name('desc_metadata__format', :stored_searchable)]).first
  end
 
  def version
    Array(self[Solrizer.solr_name('desc_metadata__version', :stored_searchable)]).first
  end
 
  def temporal
    Array(self[Solrizer.solr_name('desc_metadata__temporal', :stored_searchable)]).first
  end
 
  def dateCollected
    Array(self[Solrizer.solr_name('desc_metadata__dateCollected', :stored_searchable)]).first
  end
 
  def hasAgreement
    Array(self[Solrizer.solr_name('admin_metadata__hasAgreement', :symbol)]).first
  end
 
  def agreementTitle
    Array(self[Solrizer.solr_name('admin_metadata__agreementTitle', :stored_searchable)]).first
  end
 
  def locator_local
    Array(self[Solrizer.solr_name('admin_metadata__locator', :stored_searchable)]).first
  end
 
  def digitalSize_local
    Array(self[Solrizer.solr_name('admin_metadata__digitalSize', :stored_searchable)]).first
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
  
  def submission_workflow_all_reviewer_ids
    get(Solrizer.solr_name("MediatedSubmission_all_reviewer_ids", :symbol))
  end
  
  def digitalSizeAllocated 
    Array(self[Solrizer.solr_name('desc_metadata__digitalSizeAllocated', :stored_searchable)]).first
  end
 
  def dataStorageSilo
    Array(self[Solrizer.solr_name('desc_metadata__dataStorageSilo', :stored_searchable)]).first
  end
 
  def status
    Array(self[Solrizer.solr_name('desc_metadata__status', :stored_searchable)]).first
  end
 
  def contributor
    Array(self[Solrizer.solr_name('desc_metadata__contributor', :stored_searchable)]).first
  end

  def model
    get(Solrizer.solr_name("has_model", :symbol))
  end

  def modelName
    get("active_fedora_model_ssi")
  end

  def dateCreated
    get("system_create_dtsi")
  end

  def dateModified
    get("system_modified_dtsi")
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
