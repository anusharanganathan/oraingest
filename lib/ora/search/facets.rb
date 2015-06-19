module Ora
  module Search
    module Facets
      extend ActiveSupport::Concern
      included do
        configure_blacklight do |config|
          # solr fields that will be treated as facets by the blacklight application
          #   The ordering of the field names is the order of the display
          #config.add_facet_field solr_name("desc_metadata__resource_type", :facetable), :label => "Resource Type", :limit => 10
          config.add_facet_field solr_name("desc_metadata__type", :facetable), :label => "Resource Type", :limit => 10
          config.add_facet_field solr_name("MediatedSubmission_status", :symbol), :label => "Current Status", :limit => 15
          #config.add_facet_field solr_name("MediatedSubmission_date_submitted", :dateable), :label => "Date Submitted"
          config.add_facet_field solr_name("desc_metadata__creator", :facetable), :label => "Creator", :limit => 10
          config.add_facet_field solr_name("desc_metadata__keyword", :facetable), :label => "Keyword", :limit => 10
          config.add_facet_field solr_name("desc_metadata__subject", :facetable), :label => "Subject", :limit => 10
          config.add_facet_field solr_name("desc_metadata__language", :facetable), :label => "Language", :limit => 5
          config.add_facet_field solr_name("desc_metadata__based_near", :facetable), :label => "Location", :limit => 10
          config.add_facet_field solr_name("desc_metadata__publisher", :facetable), :label => "Publisher", :limit => 10
          config.add_facet_field "active_fedora_model_ssi", :label => "Type", :limit => 10#, :pivot => [Solrizer.solr_name("desc_metadata__type", :symbol)]
          #config.add_facet_field solr_name("file_format", :facetable), :label => "File Format", :limit => 10
          # Have BL send all facet field names to Solr, which has been the default
          # previously. Simply remove these lines if you'd rather use Solr request
          # handler defaults, or have no facets.
          config.add_facet_fields_to_solr_request!
        end
      end
    end
  end
end
