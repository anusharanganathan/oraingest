module Ora
  module Search
    module SortFields
      extend ActiveSupport::Concern
      included do
        configure_blacklight do |config|
          # "sort results by" select (pulldown)
          # label in pulldown is followed by the name of the SOLR field to sort by and
          # whether the sort is ascending or descending (it must be asc or desc
          # except in the relevancy case).
          # label is key, solr field is value
          config.add_sort_field "score desc, #{solr_name('system_create', :stored_sortable, type: :date)} desc", :label => "relevance \u2193"
          config.add_sort_field "#{solr_name('system_create', :stored_sortable, type: :date)} desc", :label => "date uploaded \u2193"
          config.add_sort_field "#{solr_name('system_create', :stored_sortable, type: :date)} asc", :label => "date uploaded \u2191"
          config.add_sort_field "#{solr_name('system_modified', :stored_sortable, type: :date)} desc", :label => "date modified \u2193"
          config.add_sort_field "#{solr_name('system_modified', :stored_sortable, type: :date)} asc", :label => "date modified \u2191"

          # If there are more than this many search results, no spelling ("did you
          # mean") suggestion is offered.
          config.spell_max = 5
        end
      end
    end
  end
end
