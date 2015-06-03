# encoding: UTF-8
class ListThesesController < ApplicationController
  include  Sufia::DashboardControllerBehavior

  layout "sufia-two-column"
  # Remove the solr_search_params_logic that we don't want applied
  # (No advanced search & Don't apply the Hydra gated discovery, which filters out all things that don't list you in their permissions.)
  # See: https://github.com/projectblacklight/blacklight/wiki/Extending-or-Modifying-Blacklight-Search-Behavior
  PublicationsController.solr_search_params_logic = CatalogController.solr_search_params_logic - [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr]

  self.copy_blacklight_config_from(CatalogController)

  # Limits search results just to GenericFile and Collection objects
  # @param solr_parameters the current solr parameters
  # @param user_parameters the current user-subitted parameters
  def exclude_unwanted_models solr_parameters, user_parameters
    solr_parameters[:fq] ||= []
    # Only include GenericFile and Collection objects
    #solr_parameters[:fq] << "active_fedora_model_ssi:GenericFile OR active_fedora_model_ssi:Collection"
    solr_parameters[:fq] << "active_fedora_model_ssi:Thesis"
  end
end
