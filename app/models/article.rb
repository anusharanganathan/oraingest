# app/models/journal_article.rb
# a Fedora object for the Article hydra content type
class Article < ActiveFedora::Base
  include Hydra::ModelMethods
  include Hydra::Datastream
  
  has_metadata :name => "descMetadata", :type=> ArticleModsDatastream
  has_metadata :name => "rightsMetadata", :type => Hydra::Datastream::RightsMetadata

  # The delegate method allows you to set up attributes on the model that are stored in datastreams
  # When you set :unique=>"true", searches will return a single value instead of an array.
  delegate :uuid, :to=>"descMetadata", :unique=>"true"
  delegate :urn, :to=>"descMetadata", :unique=>"true"
  
  delegate :title, :to=>"descMetadata", at:[:mods, :title_info, :main_title], :unique=>"true"
  delegate :subtitle, :to=>"descMetadata", :unique=>"true"
  
  delegate :abstract, :to=>"descMetadata", :unique=>"true"
  
  delegate :journal_title, :to=>"descMetadata", :unique=>"true"
  delegate :journal_volume, :to=>"descMetadata", :unique=>"true"
  delegate :journal_issue, :to=>"descMetadata", :unique=>"true"
  delegate :start_page, :to=>"descMetadata", :unique=>"true"
  delegate :end_page, :to=>"descMetadata", :unique=>"true"
  delegate :page_numbers, :to=>"descMetadata", :unique=>"true"
  
  delegate :agent, :to=>"descMetadata"
  delegate :person, :to=>"descMetadata"
  delegate :organisation, :to=>"descMetadata"
  delegate :copyright_holder, :to=>"descMetadata"
  
  delegate :agent_first_name, :to=>"descMetadata"
  delegate :agent_last_name, :to=>"descMetadata"
  delegate :agent_terms_of_address, :to=>"descMetadata"
  delegate :agent_display_name, :to=>"descMetadata"
  delegate :agent_role, :to=>"descMetadata"
  delegate :agent_webauth, :to=>"descMetadata"
  delegate :agent_pid, :to=>"descMetadata"
  delegate :agent_institution, :to=>"descMetadata"
  delegate :agent_faculty, :to=>"descMetadata"
  delegate :agent_research_group, :to=>"descMetadata"
  delegate :agent_oxford_college, :to=>"descMetadata"
  delegate :agent_affiliation, :to=>"descMetadata"
  delegate :agent_funder, :to=>"descMetadata"
  delegate :agent_grant_number, :to=>"descMetadata"
  delegate :agent_website, :to=>"descMetadata"
  delegate :agent_email, :to=>"descMetadata"
  delegate :agent_rights_ownership, :to=>"descMetadata"
  delegate :agent_third_party_copyright, :to=>"descMetadata"
  
  delegate :type, :to=>"descMetadata"
  delegate :subtype, :to=>"descMetadata"
  
  delegate :publication_date, :to=>"descMetadata", :unique=>"true"
  delegate :creation_date, :to=>"descMetadata", :unique=>"true"
  delegate :copyright_date, :to=>"descMetadata", :unique=>"true"
  
  delegate :language, :to=>"descMetadata"
  delegate :physical_description, :to=>"descMetadata"
  delegate :subject, :to=>"descMetadata"
  delegate :keyword, :to=>"descMetadata"
  delegate :license, :to=>"descMetadata", :unique=>"true"
  
  delegate :identifier, :to=>"descMetadata"
  delegate :local_id, :to=>"descMetadata"
  delegate :doi, :to=>"descMetadata", :unique=>"true"
  delegate :issn, :to=>"descMetadata", :unique=>"true"
  delegate :eissn, :to=>"descMetadata", :unique=>"true"
  delegate :publisher_id, :to=>"descMetadata", :unique=>"true"
  delegate :barcode, :to=>"descMetadata", :unique=>"true"
  delegate :pii, :to=>"descMetadata", :unique=>"true"
  delegate :article_number, :to=>"descMetadata", :unique=>"true"
  
  delegate :note, :to=>"descMetadata", :unique=>"true"
  delegate :publisher_note, :to=>"descMetadata", :unique=>"true"
  delegate :admin_note, :to=>"descMetadata", :unique=>"true"
  
  delegate :related_item, :to=>"descMetadata"


end
