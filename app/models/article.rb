# app/models/journal_article.rb
# a Fedora object for the Article hydra content type
class Article < ActiveFedora::Base
  #include Hydra::ModelMethods
  #include Hydra::Datastream
  
  has_metadata :name => "descMetadata", :type=> Datastream::ArticleModsDatastream
  has_metadata :name => "rightsMetadata", :type => Hydra::Datastream::RightsMetadata
  has_metadata :name => "recordStatus", :type => Datastream::RecordStatusDatastream

  # The delegate method allows you to set up attributes on the model that are stored in datastreams
  # When you set :unique=>"true", searches will return a single value instead of an array.
  delegate :uuid, :to=>"descMetadata", :unique=>"true"
  delegate :urn, :to=>"descMetadata", :unique=>"true"
  delegate :title, :to=>"descMetadata", at:[:mods, :title_info, :main_title], :unique=>"true"
  delegate :subtitle, :to=>"descMetadata", :unique=>"true"
  delegate :abstract, :to=>"descMetadata", :unique=>"true"
  # journal details
  delegate :journal_title, :to=>"descMetadata", :unique=>"true"
  delegate :journal_volume, :to=>"descMetadata", :unique=>"true"
  delegate :journal_issue, :to=>"descMetadata", :unique=>"true"
  delegate :start_page, :to=>"descMetadata", :unique=>"true"
  delegate :end_page, :to=>"descMetadata", :unique=>"true"
  delegate :page_numbers, :to=>"descMetadata", :unique=>"true"
  #people details
  #delegate :agent, :to=>"descMetadata"
  delegate :person, :to=>"descMetadata", at:[@person]
  delegate :organisation, :to=>"descMetadata"
  delegate :copyright_holder, :to=>"descMetadata"
  delegate :type_of_resource, :to=>"descMetadata"
  delegate :type, :to=>"descMetadata"
  delegate :subtype, :to=>"descMetadata"
  delegate :publication_date, :to=>"descMetadata", :unique=>"true"
  delegate :creation_date, :to=>"descMetadata", :unique=>"true"
  delegate :copyright_date, :to=>"descMetadata", :unique=>"true"
  delegate :language, :to=>"descMetadata"
  #physical description
  #delegate :physical_description, :to=>"descMetadata"
  delegate :digital_origin, :to=>"descMetadata"
  delegate :status, :to=>"descMetadata"
  delegate :peer_reviewed, :to=>"descMetadata"
  delegate :version, :to=>"descMetadata"
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
  #Related item
  delegate :related_item, :to=>"descMetadata"
  delegate :related_item_enumerated, :to=>"descMetadata"
  delegate :related_item_preceding, :to=>"descMetadata"
  delegate :related_item_succeeding, :to=>"descMetadata"
  delegate :related_item_original, :to=>"descMetadata"
  delegate :related_item_host, :to=>"descMetadata"
  delegate :related_item_constituent, :to=>"descMetadata"
  delegate :related_item_series, :to=>"descMetadata"
  delegate :related_item_otherVersion, :to=>"descMetadata"
  delegate :related_item_otherFormat, :to=>"descMetadata"
  delegate :related_item_isReferencedBy, :to=>"descMetadata"
  delegate :related_item_references, :to=>"descMetadata"
  delegate :related_item_reviewOf, :to=>"descMetadata"
end
