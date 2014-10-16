module Ora
  module Search
    module ShowFields
      extend ActiveSupport::Concern
      included do
        configure_blacklight do |config|
          # solr field configuration for search results/index views
          config.index.show_link = solr_name("desc_metadata__title", :displayable)
          config.index.record_display_type = "id"
          # solr field configuration for document/show views
          config.show.html_title = solr_name("desc_metadata__title", :displayable)
          config.show.heading = solr_name("desc_metadata__title", :displayable)
          config.show.display_type = solr_name("has_model", :symbol)
          # solr fields to be displayed in the show (single result) view
          # The ordering of the field names is the order of the display
          config.add_show_field solr_name("desc_metadata__title", :stored_searchable, type: :string), :label => "Title"
          config.add_show_field solr_name("desc_metadata__subtitle", :stored_searchable, type: :string), :label => "Subtitle"
          config.add_show_field solr_name("desc_metadata__description", :stored_searchable, type: :string), :label => "Description"
          config.add_show_field solr_name("desc_metadata__abstract", :stored_searchable, type: :string), :label => "Abstract"
          config.add_show_field solr_name("desc_metadata__type", :stored_searchable, type: :string), :label => "Document type"
          config.add_show_field solr_name("desc_metadata__type_category", :stored_searchable, type: :string), :label => "Document category"
          config.add_show_field solr_name("desc_metadata__creator", :stored_searchable, type: :string), :label => "Creator"
          config.add_show_field solr_name("desc_metadata__contributor", :stored_searchable, type: :string), :label => "Contributor"
          config.add_show_field solr_name("desc_metadata__publisher", :stored_searchable, type: :string), :label => "Publisher"
          config.add_show_field solr_name("desc_metadata__keyword", :stored_searchable, type: :string), :label => "Keyword"
          config.add_show_field solr_name("desc_metadata__subject", :stored_searchable, type: :string), :label => "Subject"
          config.add_show_field solr_name("desc_metadata__medium", :stored_searchable, type: :string), :label => "Medium"
          config.add_show_field solr_name("desc_metadata__edition", :stored_searchable, type: :string), :label => "Edition"
          config.add_show_field solr_name("desc_metadata__numPages", :stored_searchable, type: :string), :label => "Number of pages"
          config.add_show_field solr_name("desc_metadata__pages", :stored_searchable, type: :string), :label => "Page range"
          config.add_show_field solr_name("desc_metadata__publicationStatus", :stored_searchable, type: :string), :label => "Publication status"
          config.add_show_field solr_name("desc_metadata__reviewStatus", :stored_searchable, type: :string), :label => "Review status"
          #config.add_show_field solr_name("desc_metadata__based_near", :stored_searchable, type: :string), :label => "Location"
          #config.add_show_field solr_name("desc_metadata__date_uploaded", :stored_searchable, type: :string), :label => "Date Uploaded"
          config.add_show_field solr_name("desc_metadata__date_modified", :stored_searchable, type: :string), :label => "Date Modified"
          config.add_show_field solr_name("desc_metadata__date_created", :stored_searchable, type: :string), :label => "Date Created"
          #config.add_show_field solr_name("desc_metadata__rights", :stored_searchable, type: :string), :label => "Rights"
          #config.add_show_field solr_name("desc_metadata__resource_type", :stored_searchable, type: :string), :label => "Resource Type"
          #config.add_show_field solr_name("desc_metadata__format", :stored_searchable, type: :string), :label => "File Format"
          config.add_show_field solr_name("desc_metadata__identifier", :stored_searchable, type: :string), :label => "Identifier"
          config.add_show_field solr_name("desc_metadata__language", :stored_searchable, type: :string), :label => "language"
          config.add_show_field solr_name("desc_metadata__languageCode", :stored_searchable, type: :string), :label => "Language code"
          config.add_show_field solr_name("desc_metadata__languageAuthority", :stored_searchable, type: :text), :label => "Language authority"
          config.add_show_field solr_name("desc_metadata__languageScheme", :stored_searchable, type: :text), :label => "Language scheme"
        end
      end
    end
  end
end
