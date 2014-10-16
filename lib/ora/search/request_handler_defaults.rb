module Ora
  module Search
    module RequestHandlerDefaults
      extend ActiveSupport::Concern
      included do
        configure_blacklight do |config|
          # Now we see how to over-ride Solr request handler defaults, in this
          # case for a BL "search field", which is really a dismax aggregate
          # of Solr search fields.
          # creator, title, description, publisher, date_created,
          # subject, language, resource_type, format, identifier, based_near,
          config.add_search_field('contributor') do |field|
            # solr_parameters hash are sent to Solr as ordinary url query params.
            field.solr_parameters = { :"spellcheck.dictionary" => "contributor" }

            # :solr_local_parameters will be sent using Solr LocalParams
            # syntax, as eg {! qf=$title_qf }. This is neccesary to use
            # Solr parameter de-referencing like $title_qf.
            # See: http://wiki.apache.org/solr/LocalParams
            solr_name = solr_name("desc_metadata__contributor", :stored_searchable, type: :string)
            field.solr_local_parameters = {
              :qf => solr_name,
              :pf => solr_name
            }
          end
         

          config.add_search_field('creator') do |field|
            field.solr_parameters = { :"spellcheck.dictionary" => "creator" }
            solr_name = solr_name("desc_metadata__creator", :stored_searchable, type: :string)
            field.solr_local_parameters = {
              :qf => solr_name,
              :pf => solr_name
            }
          end

          config.add_search_field('title') do |field|
            field.solr_parameters = {
              :"spellcheck.dictionary" => "title"
            }
            solr_name = solr_name("desc_metadata__title", :stored_searchable, type: :string)
            field.solr_local_parameters = {
              :qf => solr_name,
              :pf => solr_name
            }
          end

          config.add_search_field('subtitle') do |field|
            field.solr_parameters = {
              :"spellcheck.dictionary" => "subtitle"
            }
            solr_name = solr_name("desc_metadata__subtitle", :stored_searchable, type: :string)
            field.solr_local_parameters = {
              :qf => solr_name,
              :pf => solr_name
            }
          end

          config.add_search_field('description') do |field|
            field.label = "Abstract or Summary"
            field.solr_parameters = {
              :"spellcheck.dictionary" => "description"
            }
            solr_name = solr_name("desc_metadata__description", :stored_searchable, type: :string)
            field.solr_local_parameters = {
              :qf => solr_name,
              :pf => solr_name
            }
          end

          config.add_search_field('abstract') do |field|
            field.label = "Abstract or Summary"
            field.solr_parameters = {
              :"spellcheck.dictionary" => "abstract"
            }
            solr_name = solr_name("desc_metadata__abstract", :stored_searchable, type: :string)
            field.solr_local_parameters = {
              :qf => solr_name,
              :pf => solr_name
            }
          end

          config.add_search_field('type') do |field|
            field.label = "Document type"
            field.solr_parameters = {
              :"spellcheck.dictionary" => "type"
            }
            solr_name = solr_name("desc_metadata__type", :stored_searchable, type: :string)
            field.solr_local_parameters = {
              :qf => solr_name,
              :pf => solr_name
            }
          end

          config.add_search_field('type_category') do |field|
            field.label = "Document category"
            field.solr_parameters = {
              :"spellcheck.dictionary" => "type_category"
            }
            solr_name = solr_name("desc_metadata__type_category", :stored_searchable, type: :string)
            field.solr_local_parameters = {
              :qf => solr_name,
              :pf => solr_name
            }
          end

          config.add_search_field('publisher') do |field|
            field.solr_parameters = {
              :"spellcheck.dictionary" => "publisher"
            }
            solr_name = solr_name("desc_metadata__publisher", :stored_searchable, type: :string)
            field.solr_local_parameters = {
              :qf => solr_name,
              :pf => solr_name
            }
          end

          config.add_search_field('date_created') do |field|
            field.solr_parameters = {
              :"spellcheck.dictionary" => "date_created"
            }
            solr_name = solr_name("desc_metadata__created", :stored_searchable, type: :string)
            field.solr_local_parameters = {
              :qf => solr_name,
              :pf => solr_name
            }
          end

          config.add_search_field('subject') do |field|
            field.solr_parameters = {
              :"spellcheck.dictionary" => "subject"
            }
            solr_name = solr_name("desc_metadata__subject", :stored_searchable, type: :string)
            field.solr_local_parameters = {
              :qf => solr_name,
              :pf => solr_name
            }
          end

          config.add_search_field('language') do |field|
            field.solr_parameters = {
              :"spellcheck.dictionary" => "language"
            }
            solr_name = solr_name("desc_metadata__language", :stored_searchable, type: :string)
            field.solr_local_parameters = {
              :qf => solr_name,
              :pf => solr_name
            }
          end

          config.add_search_field('identifier') do |field|
            field.include_in_advanced_search = false
            field.solr_parameters = {
              :"spellcheck.dictionary" => "identifier"
            }
            solr_name = solr_name("desc_metadata__id", :stored_searchable, type: :string)
            field.solr_local_parameters = {
              :qf => solr_name,
              :pf => solr_name
            }
          end

          config.add_search_field('depositor') do |field|
            solr_name = solr_name("desc_metadata__depositor", :stored_searchable, type: :string)
            field.solr_local_parameters = {
              :qf => solr_name,
              :pf => solr_name
            }
          end

          config.add_search_field('rights') do |field|
            solr_name = solr_name("desc_metadata__rights", :stored_searchable, type: :string)
            field.solr_local_parameters = {
              :qf => solr_name,
              :pf => solr_name
            }
          end

        end
      end
    end
  end
end
