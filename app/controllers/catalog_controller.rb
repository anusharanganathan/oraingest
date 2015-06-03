# -*- coding: utf-8 -*-
# Copyright © 2012 The Pennsylvania State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# -*- encoding : utf-8 -*-
require 'blacklight/catalog'
require 'blacklight_advanced_search'

# bl_advanced_search 1.2.4 is doing unitialized constant on these because we're calling ParseBasicQ directly
require 'parslet'  
require 'parsing_nesting/tree'

class CatalogController < ApplicationController
  include Blacklight::Catalog
  # Extend Blacklight::Catalog with Hydra behaviors (primarily editing).
  include Hydra::Controller::ControllerBehavior
  include BlacklightAdvancedSearch::ParseBasicQ
  # Include ORA search logic
  include Ora::Search::Defaults
  include Ora::Search::ViewConfiguration
  include Ora::Search::Facets
  include Ora::Search::IndexFields
  include Ora::Search::SearchFields
  include Ora::Search::ShowFields
  include Ora::Search::RequestHandlerDefaults
  include Ora::Search::SortFields

  layout :search_layout

  # These before_filters apply the hydra access controls
  before_filter :enforce_show_permissions, :only=>:show
  # This applies appropriate access controls to all solr queries
  CatalogController.solr_search_params_logic += [:add_access_controls_to_solr_params]
  # This filters out objects that you want to exclude from search results, like FileAssets
  CatalogController.solr_search_params_logic += [:exclude_unwanted_models]

  skip_before_filter :default_html_head

  def index
    super
    #recent
    #also grab my recent docs too
    #recent_me
    #grab my recent publications
    my_recent_publications
    #grab my recent publications
    my_recent_datasets
    my_recent_theses
  end

  def recent
    if user_signed_in?
      # grab other people's documents
      (_, @recent_documents) = get_search_results(:q =>filter_not_mine,
                                        :sort=>sort_field, :rows=>4)      
    else 
      # grab any documents we do not know who you are
      (_, @recent_documents) = get_search_results(:q =>'', :sort=>sort_field, :rows=>4)
    end
  end

  def recent_me
    if user_signed_in?
      (_, @recent_user_documents) = get_search_results(:q =>filter_not_mine,
                                        :sort=>sort_field, :rows=>4)
    end
  end

  def my_recent_publications
    if user_signed_in?
      (_, @recent_publications) = get_search_results(:q =>filter_mine_publications,
                                        :sort=>sort_field, :rows=>5)
    end
  end

  def my_recent_datasets
    if user_signed_in?
      (_, @recent_datasets) = get_search_results(:q =>filter_mine_datasets,
                                        :sort=>sort_field, :rows=>5)
    end
  end

  def my_recent_theses
    if user_signed_in?
      (_, @recent_theses) = get_search_results(:q =>filter_mine_theses,
                                               :sort=>sort_field, :rows=>5)
    end
  end

  protected

  # Limits search results just to needed models
  # @param solr_parameters the current solr parameters
  # @param user_parameters the current user-subitted parameters
  def exclude_unwanted_models(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "#{Solrizer.solr_name("has_model", :symbol)}:\"info:fedora/afmodel:Article\" OR #{Solrizer.solr_name("has_model", :symbol)}:\"info:fedora/afmodel:Dataset\" OR #{Solrizer.solr_name("has_model", :symbol)}:\"info:fedora/afmodel:Thesis\""
  end

  def depositor 
    #Hydra.config[:permissions][:owner] maybe it should match this config variable, but it doesn't.
    Solrizer.solr_name('depositor', :stored_searchable, type: :string)
  end

  def s_model
    Solrizer.solr_name("has_model", :symbol)
  end

  def filter_not_mine 
    "{!lucene q.op=AND df=#{depositor}}-#{current_user.user_key}"
  end

  def filter_mine_publications
    "{!lucene q.op=AND} #{depositor}:#{current_user.user_key} -#{s_model}:\"info:fedora/afmodel:Dataset\""
  end

  def filter_mine_datasets
    "{!lucene q.op=AND} #{depositor}:#{current_user.user_key} #{s_model}:\"info:fedora/afmodel:Dataset\""
  end

  def filter_mine_theses
    "{!lucene q.op=AND} #{depositor}:#{current_user.user_key} #{s_model}:\"info:fedora/afmodel:Thesis\""
  end

  def sort_field
    "#{Solrizer.solr_name('system_modified', :sortable)} desc"
  end


end
