module Ora
  module Search
    module IndexFields
      extend ActiveSupport::Concern
      included do
        configure_blacklight do |config|
          # solr fields to be displayed in the index (search results) view
          #   The ordering of the field names is the order of the display
          config.add_index_field solr_name("MediatedSubmission_status", :symbol), :label => "Workflow Status"
          config.add_index_field solr_name("MediatedSubmission_date_submitted", :dateable), :label => "Date Submitted"
          config.add_index_field solr_name("desc_metadata__title", :stored_searchable, type: :string), :label => "Title"
          config.add_index_field solr_name("desc_metadata__subtitle", :stored_searchable, type: :string), :label => "Subtitle"
          config.add_index_field solr_name("desc_metadata__description", :stored_searchable, type: :string), :label => "Description"
          config.add_index_field solr_name("desc_metadata__abstract", :stored_searchable, type: :string), :label => "Abstract"
          config.add_index_field solr_name("desc_metadata__type", :stored_searchable, type: :string), :label => "Document type"
          config.add_index_field solr_name("desc_metadata__type_category", :stored_searchable, type: :string), :label => "Document category"
          config.add_index_field solr_name("desc_metadata__creator", :stored_searchable, type: :string), :label => "Creator"
          config.add_index_field solr_name("desc_metadata__contributor", :stored_searchable, type: :string), :label => "Contributor"
          config.add_index_field solr_name("desc_metadata__publisher", :stored_searchable, type: :string), :label => "Publisher"
          config.add_index_field solr_name("desc_metadata__keyword", :stored_searchable, type: :string), :label => "Keyword"
          config.add_index_field solr_name("desc_metadata__subject", :stored_searchable, type: :string), :label => "Subject"
          config.add_index_field solr_name("desc_metadata__medium", :stored_searchable, type: :string), :label => "Medium"
          config.add_index_field solr_name("desc_metadata__edition", :stored_searchable, type: :string), :label => "Edition"
          config.add_index_field solr_name("desc_metadata__numPages", :stored_searchable, type: :string), :label => "Number of pages"
          config.add_index_field solr_name("desc_metadata__pages", :stored_searchable, type: :string), :label => "Page range"
          config.add_index_field solr_name("desc_metadata__publicationStatus", :stored_searchable, type: :string), :label => "Publication status"
          config.add_index_field solr_name("desc_metadata__reviewStatus", :stored_searchable, type: :string), :label => "Review status"
          #config.add_index_field solr_name("desc_metadata__date_uploaded", :stored_searchable, type: :string), :label => "Date Uploaded"
          config.add_index_field solr_name("desc_metadata__date_modified", :stored_searchable, type: :string), :label => "Date Modified"
          config.add_index_field solr_name("desc_metadata__date_created", :stored_searchable, type: :string), :label => "Date Created"
          #config.add_index_field solr_name("desc_metadata__rights", :stored_searchable, type: :string), :label => "Rights"
          #config.add_index_field solr_name("desc_metadata__resource_type", :stored_searchable, type: :string), :label => "Resource Type"
          #config.add_index_field solr_name("desc_metadata__format", :stored_searchable, type: :string), :label => "File Format"
          config.add_index_field solr_name("desc_metadata__identifier", :stored_searchable, type: :string), :label => "Identifier"
          config.add_index_field solr_name("desc_metadata__language", :stored_searchable, type: :string), :label => "language"
          config.add_index_field solr_name("desc_metadata__languageCode", :stored_searchable, type: :string), :label => "Language code"
          config.add_index_field solr_name("desc_metadata__languageAuthority", :stored_searchable, type: :text), :label => "Language authority"
          config.add_index_field solr_name("desc_metadata__languageScheme", :stored_searchable, type: :text), :label => "Language scheme"
        end
      end
    end
  end
end
