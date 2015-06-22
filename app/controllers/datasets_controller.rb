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

require "utils"

require 'json'

class DatasetsController < ApplicationController
  before_action :set_dataset, only: [:show, :edit, :update, :destroy, :revoke_permissions]
  include Blacklight::Catalog
  # Extend Blacklight::Catalog with Hydra behaviors (primarily editing).
  include Hydra::Controller::ControllerBehavior
  include BlacklightAdvancedSearch::ParseBasicQ
  include BlacklightAdvancedSearch::Controller
  include Sufia::Controller
  #include Sufia::FilesControllerBehavior
  # Include ORA search logic
  include Ora::Search::Defaults
  include Ora::Search::ViewConfiguration
  include Ora::Search::Facets
  include Ora::Search::IndexFields
  #include Ora::Search::ShowFields
  include Ora::Search::SearchFields
  #include Ora::Search::RequestHandlerDefaults
  include Ora::Search::SortFields

  layout "sufia-two-column"    

  # These before_filters apply the hydra access controls
  #before_filter :enforce_show_permissions, :only=>:show
  before_filter :authenticate_user!, :except => [:show, :citation]
  before_filter :has_access?
  #respond_to :js, only: :agreement
  # This applies appropriate access controls to all solr queries
  DatasetsController.solr_search_params_logic += [:add_access_controls_to_solr_params]
  # This filters out objects that you want to exclude from search results, like FileAssets
  #DatasetsController.solr_search_params_logic += [:exclude_unwanted_models]

  skip_before_filter :default_html_head

  # Catch permission errors
  rescue_from Hydra::AccessDenied, CanCan::AccessDenied do |exception|
    if exception.action != :show && exception.action != :index
      redirect_to action: 'show', alert: "You do not have sufficient privileges to modify this dataset"
      #redirect_to action: 'show'
    elsif exception.action == :show
      redirect_to datasets_path, alert: "You do not have sufficient privileges to view this dataset"
      #redirect_to action: 'index', alert: "You do not have sufficient privileges to view this dataset"
    elsif current_user and current_user.persisted?
      redirect_to datasets_path, alert: exception.message
      #redirect_to action: 'index', alert: exception.message
    else
      session["user_return_to"] = request.url
      redirect_to new_user_session_url, :alert => exception.message
      #redirect_to new_user_session_url
    end
  end

  def show
    authorize! :show, params[:id]
    @pid = params[:id]
    @files = contents
    @model = 'dataset'
  end

  def new
    @pid = Sufia::Noid.noidify(SecureRandom.uuid)
    @pid = Sufia::Noid.namespaceize(@pid)
    @dataset = Dataset.new
    @files = []
    @agreement = DatasetAgreement.new
    @agreement.title = "Agreement for #{@pid}"
    @agreement.agreementType = "Individual"
    @agreement.contributor = current_user.user_key
    @dataset.hasRelatedAgreement = @agreement
    relevant_agreements
    principal_agreement
    @model = 'dataset'
  end

  def edit
    # Only edits for drafts and referred allowed. Not published items. So need not check for doi_requested in workflow
    authorize! :edit, params[:id]
    unless Sufia.config.next_workflow_status.keys.include?(@dataset.workflows.first.current_status)
      raise CanCan::AccessDenied.new("Not authorized to edit while record is being migrated!", :read, Dataset)
    end
    if @dataset.workflows.first.current_status != "Draft" && @dataset.workflows.first.current_status !=  "Referred"
      authorize! :review, params[:id]
    end
    @pid = params[:id]
    @files = contents
    if @files.any?
      unless @dataset.medium.any? && @dataset.medium.include?(Sufia.config.data_medium["Digital"])
        @dataset.medium[0] = Sufia.config.data_medium["Digital"]
      end
    end
    relevant_agreements
    principal_agreement
    @model = 'dataset'
    if @dataset.hasRelatedAgreement.nil?
      @agreement = DatasetAgreement.new
      @agreement.title = "Agreement for #{@pid}"
      @agreement.agreementType = "Individual"
      @agreement.contributor = current_user.user_key
      @dataset.hasRelatedAgreement = @agreement
    end
  end

  def create
    @pid = params[:pid]
    @dataset = Dataset.find_or_create(@pid)
    @dataset.apply_permissions(current_user) 
    if params.has_key?(:files)
      create_from_upload(params)
    elsif params.has_key?(:dataset)
      add_metadata(params[:dataset], "")
    else
      format.html { render action: 'edit' }
      format.json { render json: @dataset.errors, status: :unprocessable_entity }
    end

     #format.html { redirect_to action: 'show', id: @dataset.id }
     #format.json { render action: 'show', status: :created, location: @dataset }
  end

  def update
    @pid = params[:pid]
    redirect_field = ""
    if params.has_key?(:redirect_field)
      redirect_field = params[:redirect_field]
    end
    if params.has_key?(:files)
      create_from_upload(params)
    elsif dataset_params
      add_metadata(params[:dataset], redirect_field)
    else
      format.html { render action: 'edit' }
      format.json { render json: @dataset.errors, status: :unprocessable_entity }
    end
  end

  def destroy
    authorize! :destroy, params[:id]
    unless Sufia.config.next_workflow_status.keys.include?(@dataset.workflows.first.current_status)
      raise CanCan::AccessDenied.new("Not authorized to edit while record is being migrated!", :read, Dataset)
    end
    if @dataset.workflows.first.current_status != "Draft" && @dataset.workflows.first.current_status !=  "Referred"
       authorize! :review, params[:id]
    end
    @dataset.delete_dir(force=true)
    @dataset.destroy
    respond_to do |format|
      format.html { redirect_to datasets_url }
      format.json { head :no_content }
    end
    #TODO: If associated with an individual agreement, do we delete it? 
    #      Especially, if the status of agreement is new?
  end

  def agreement
    @model = 'dataset_agreement'
    @agreement = nil
    agreement_id = params[:a_id]
    if agreement_id == "new"
      agreement_id = nil
    end
    if !agreement_id.nil? && !agreement_id.empty?
      begin
        @agreement = DatasetAgreement.find(agreement_id)
      rescue ActiveFedora::ObjectNotFoundError
        @agreement = nil
      end
    end
    if @agreement.nil?
      @agreement = DatasetAgreement.new
      if !params[:id].nil? && !params[:id].empty?
        @agreement.title = "Agreement for #{params[:id]}"
      else
        @agreement.title = "Agreement for data deposit"
      end
      @agreement.agreementType = "Individual"
      @agreement.contributor = current_user.user_key
      @agreement.apply_permissions(current_user)
    end
    render :partial => "dataset_agreement_fields_edit", :locals => { :hasRelatedAgreement => @agreement }
  end

  #def recent
  #  if user_signed_in?
  #    # grab other people's documents
  #    (_, @recent_documents) = get_search_results(:q =>filter_not_mine,
  #                                      :sort=>sort_field, :rows=>5)
  #  else 
  #    # grab any documents we do not know who you are
  #    (_, @recent_documents) = get_search_results(:q =>'', :sort=>sort_field, :rows=>5)
  #  end
  #end

  #def recent_me
  #  if user_signed_in?
  #    (_, @recent_user_documents) = get_search_results(:q =>filter_mine,
  #                                      :sort=>sort_field, :rows=>50, :fields=>"*:*")
  #  end
  #end

  #def recent_me_draft
  #  if user_signed_in?
  #    (_, @datasets) = get_search_results(:q =>filter_mine_draft,
  #                                      :sort=>sort_field, :rows=>50, :fields=>"*:*")
  #  end
  #end

  #def recent_me_not_draft
  #  if user_signed_in?
  #    (_, @submitted_datasets) = get_search_results(:q =>filter_mine_not_draft,
  #                                      :sort=>sort_field, :rows=>50, :fields=>"*:*")
  #  end
  #end

  def relevant_agreements
    # All people including the data steward should be listed in the contributor, if allowed to contribute
    if user_signed_in?
      (_, @relevant_user_agreements) = get_search_results(:q =>filter_relevant_agreement, 
                                        :sort=>sort_field, :rows=>5, :fields=>"*:*")
    end
  end

  def principal_agreement
    if user_signed_in?
      (_, @principal_agreement) = get_search_results(:q =>filter_principal_agreement, 
                                        :sort=>sort_field, :rows=>5, :fields=>"*:*")
    end
  end

  def self.uploaded_field
    #system_create_dtsi
    solr_name('desc_metadata__date_uploaded', :stored_sortable, type: :date)
  end

  def self.modified_field
    solr_name('desc_metadata__date_modified', :stored_sortable, type: :date)
  end

  def create_from_upload(params)
    # check error condition No files
    return json_error("Error! No file to save") if !params.has_key?(:files)
    file = params[:files].detect {|f| f.respond_to?(:original_filename) }
    if !file
      return json_error "Error! No file for upload", 'unknown file', :status => :unprocessable_entity
    elsif (empty_file?(file))
      return json_error "Error! Zero Length File!", file.original_filename
    else
      process_file(file)
    end
  rescue => error
    logger.error "DatasetsController::create_from_upload rescued #{error.class}\n\t#{error.to_s}\n #{error.backtrace.join("\n")}\n\n"
    json_error "Error occurred while creating file."
  ensure
    # remove the tempfile (only if it is a temp file)
    file.tempfile.delete if file.respond_to?(:tempfile)
  end

  def process_file(file)
    # Save file to disk
    filename = File.basename(file.original_filename)
    dsid = @dataset.add_content(file, filename)
    # Save the dataset
    save_tries = 0
    begin
      @dataset.save!
    rescue RSolr::Error::Http => error
      logger.warn "DatasetsController::process_file caught error #{error.inspect}"
      save_tries+=1
      # fail for good if the tries is greater than 3
      raise error if save_tries >=3
      sleep 0.01
      retry
    end

    respond_to do |format|
      format.html {
        render :json => [@dataset.to_jq_upload(file.original_filename, file.size, @dataset.id, dsid)],
        :content_type => 'text/html',
        :layout => false
      }
      format.json {
        render :json => [@dataset.to_jq_upload(file.original_filename, file.size, @dataset.id, dsid)]
      }
    end
  rescue ActiveFedora::RecordInvalid => af
    flash[:error] = af.message
    json_error "Error creating generic file: #{af.message}"
  end

  def revoke_permissions
    authorize! :destroy, params[:id]
    if params.has_key?(:access) && params.has_key?(:name) && params.has_key?(:type)
      new_params = MetadataBuilder.new(@dataset).validatePermissionsToRevoke(params, @dataset.workflowMetadata.depositor[0])
          respond_to do |format|
        if @dataset.update(new_params)
          format.html { redirect_to edit_dataset_path(@dataset), notice: 'Dataset was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @dataset.errors, status: :unprocessable_entity }
        end
      end
    else
      format.html { render action: 'edit' }
      format.json { render json: @dataset.errors, status: :unprocessable_entity }
    end 
  end

  def add_metadata(dataset_params, redirect_field)
    if !@dataset.workflows.nil? && !@dataset.workflows.first.entries.nil?
      old_status = @dataset.workflows.first.current_status
    else
      old_status = nil
    end
    # find or create the dataset agreement, if included in the params
    if dataset_params.has_key?(:hasAgreement) or dataset_params.has_key?(:hasRelatedAgreement)
      @@dataset_agreement, created = add_agreement(dataset_params)
    end
    dataset_params[:hasRelatedAgreement] = nil
    dataset_params[:hasAgreement] = nil
    if @dataset_agreement
      dataset_params[:hasAgreement] = @dataset_agreement.id
    end
    # Update params
    MetadataBuilder.new(@dataset).build(dataset_params, contents, current_user.user_key)
    if @dataset.medium.first != Sufia.config.data_medium["Digital"] && !contents.empty?
      @dataset.medium = [Sufia.config.data_medium["Digital"]]
    end
    if @dataset_agreement
      @dataset.hasRelatedAgreement = @dataset_agreement
    end
    if old_status != @dataset.workflows.first.current_status
      WorkflowPublisher.new(@dataset).perform_action(current_user)
    end
    respond_to do |format|
      if @dataset.save
        format.html { redirect_to edit_dataset_path(@dataset), notice: 'Dataset was successfully updated.', flash: { redirect_field: redirect_field } }
        format.json { head :no_content }
      else
        # If a dataset agreement was created newly, roll back changes
        if @dataset_agreement and created
          @dataset_agreement.destroy
        end
        format.html { render action: 'edit' }
        format.json { render json: @dataset.errors, status: :unprocessable_entity }
      end
    end
  end

  def contents
    files = []
    @dataset.content_datastreams.each do |dsid|
      opts = @dataset.datastream_opts(dsid)
      files.push(@dataset.to_jq_upload(opts['dsLabel'], opts['size'], @dataset.id, dsid))
    end
    files
  end

  def add_agreement(dataset_params)
    @dataset_agreement = nil
    created = false
    da_pid = nil
    # Get the parameter and sanitize it
    if dataset_params.has_key?(:hasAgreement) and !dataset_params[:hasAgreement].empty?
      da_pid = dataset_params[:hasAgreement]
      if da_pid == "new" || da_pid.empty? || da_pid == ""
        da_pid = nil
      end
    end
    # Try to extract the dataset agreement
    if !da_pid.nil?
      begin
        @dataset_agreement = DatasetAgreement.find(da_pid)
      rescue ActiveFedora::ObjectNotFoundError
        da_pid = nil
      end
    end
    # Mint a pid if one does not exist
    if da_pid.nil?
      da_pid = Sufia::Noid.noidify(SecureRandom.uuid)
      da_pid = Sufia::Noid.namespaceize(da_pid)
      created = true
    end  
    if (@dataset_agreement.nil? or @dataset_agreement.agreementType.first == "Individual") and dataset_params.has_key?(:hasRelatedAgreement)
      dataset_agreement_params = {}
      dataset_agreement_params = dataset_params[:hasRelatedAgreement]
      if @dataset_agreement.nil?
        @dataset_agreement = DatasetAgreement.find_or_create(da_pid)
        @dataset_agreement.apply_permissions(current_user)
      end
      dataset_agreement_params[:title] = "Agreement for #{@dataset.id}"
      dataset_agreement_params[:agreementType] = "Individual"
      dataset_agreement_params[:contributor] = current_user.user_key
      MetadataBuilder.new(@dataset_agreement).build(dataset_agreement_params, [], current_user.user_key)
      if !@dataset_agreement.save
        @dataset_agreement = nil
      end 
    end
    return @dataset_agreement, created
  end

  private
  def dataset_params
    #  #params.require(:dataset).permit(:title, :subtitle, :description, :abstract, {:keyword => []}, :medium, :numPages, :pages, :publicationStatus, :reviewStatus, :language, :language_attributes, :workflows, :workflows_attributes, :permissions, :permissions_attributes, :subject, :scheme, :elementList, :externalAuthority, :topicElement_attributes, :topicElement, :scheme_attributes)
    #  params.require(:dataset).permit!
    params.require(:dataset)
  end

  def set_dataset
    @dataset = Dataset.find(params[:id])
  end

  protected

  # Limits search results just to GenericFiles
  # @param solr_parameters the current solr parameters
  # @param user_parameters the current user-subitted parameters

  def exclude_unwanted_models(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "#{Solrizer.solr_name("has_model", :symbol)}:\"info:fedora/afmodel:Dataset\""
  end

  def depositor
    #Hydra.config[:permissions][:owner] maybe it should match this config variable, but it doesn't.
    Solrizer.solr_name('depositor', :stored_searchable, type: :string)
  end

  def workflow_status
    #Hydra.config[:permissions][:owner] maybe it should match this config variable, but it doesn't.
    Solrizer.solr_name('all_workflow_statuses', :stored_searchable, type: :symbol)
  end

  def s_model
    Solrizer.solr_name("has_model", :symbol)
  end

  def s_contributor
    Solrizer.solr_name("desc_metadata__contributor", :stored_searchable)
  end

  def s_editor
    Solrizer.solr_name('edit_access_person', :symbol, type: :string)
  end

  def s_type
    Solrizer.solr_name("desc_metadata__agreementType", :symbol)
  end

  #def filter_not_mine 
  #  "{!lucene q.op=AND #{depositor}:-#{current_user.user_key} #{s_model}:\"info:fedora/afmodel:Dataset\""
  #end

  #def filter_mine
  #  "{!lucene q.op=AND #{depositor}:#{current_user.user_key} #{s_model}:\"info:fedora/afmodel:Dataset\""
  #end

  #def filter_mine_draft
  #  "{!lucene q.op=AND} #{depositor}:#{current_user.user_key} #{workflow_status}:Draft #{s_model}:\"info:fedora/afmodel:Dataset\""
  #end

  #def filter_mine_not_draft
  #  "{!lucene q.op=AND} #{depositor}:#{current_user.user_key} -#{workflow_status}:Draft #{s_model}:\"info:fedora/afmodel:Dataset\""
  #end

  def filter_relevant_agreement
    # All people including the data steward should be listed in the contributor, if allowed to contribute
    "{!lucene q.op=AND} #{s_model}:\"info:fedora/afmodel:DatasetAgreement\" #{s_contributor}:#{current_user.user_key} #{s_type}:Bilateral"
  end

  def filter_principal_agreement
    "{!lucene q.op=AND} #{s_model}:\"info:fedora/afmodel:DatasetAgreement\" #{s_type}:Principal"
  end

  def filter_my_agreement
    # All people including the data steward should be listed in the contributor, if allowed to contribute
    # I do not need the person who signed the agreement here
    "{!lucene q.op=AND} #{s_model}:\"info:fedora/afmodel:DatasetAgreement\" #{s_editor}:#{current_user.user_key} #{s_type}:Bilateral"
  end

  def sort_field
    "#{Solrizer.solr_name('system_create', :sortable)} desc"
  end

  def has_access?
    true
  end

  def json_error(error, name=nil, additional_arguments={})
    args = {:error => error}
    args[:name] = name if name
    #render additional_arguments.merge({:json => [args]})
  end

  def empty_file?(file)
    (file.respond_to?(:tempfile) && file.tempfile.size == 0) || (file.respond_to?(:size) && file.size == 0)
  end

end
