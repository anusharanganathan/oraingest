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
          #config.add_sort_field "score desc, #{uploaded_field} desc", :label => "relevance \u25BC"
          #config.add_sort_field "#{uploaded_field} desc", :label => "date uploaded \u25BC"
          #config.add_sort_field "#{uploaded_field} asc", :label => "date uploaded \u25B2"
          #config.add_sort_field "#{modified_field} desc", :label => "date modified \u25BC"
          #config.add_sort_field "#{modified_field} asc", :label => "date modified \u25B2"

          # If there are more than this many search results, no spelling ("did you
          # mean") suggestion is offered.
          config.spell_max = 5
        end
      end
    end
  end
end
