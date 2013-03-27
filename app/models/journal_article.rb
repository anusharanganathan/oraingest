# app/models/journal_article.rb
# a Fedora object for the Journal Article hydra content type
class JournalArticle < ActiveFedora::Base
  include Hydra::ModelMethods
  include Hydra::Datastream
  
  has_metadata :name => "descMetadata", :type=> JournalArticleModsDatastream
  has_metadata :name => "rightsMetadata", :type => Hydra::Datastream::RightsMetadata


  # The delegate method allows you to set up attributes on the model that are stored in datastreams
  # When you set :unique=>"true", searches will return a single value instead of an array.
  delegate :title, :to=>"descMetadata", :unique=>"true"
  delegate :abstract, :to=>"descMetadata", :unique=>"true"

  delegate :start_page, :to=>"descMetadata"
  delegate :end_page, :to=>"descMetadata"
  delegate :publication_date, :to=>"descMetadata"
  delegate :journal_title, :to=>"descMetadata"
  delegate :journal_volume, :to=>"descMetadata"
  delegate :journal_issue, :to=>"descMetadata"

end
