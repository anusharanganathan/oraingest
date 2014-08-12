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
require 'ora/build_metadata'

class DatasetsController < ApplicationController
  before_action :set_dataset, only: [:show, :edit, :update, :destroy, :revoke_permissions]
  include Blacklight::Catalog
  # Extend Blacklight::Catalog with Hydra behaviors (primarily editing).
  include Hydra::Controller::ControllerBehavior
  include BlacklightAdvancedSearch::ParseBasicQ
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

  # These before_filters apply the hydra access controls
  #before_filter :enforce_show_permissions, :only=>:show
  before_filter :authenticate_user!, :except => [:show, :citation]
  before_filter :has_access?
  # This applies appropriate access controls to all solr queries
  DatasetsController.solr_search_params_logic += [:add_access_controls_to_solr_params]
  # This filters out objects that you want to exclude from search results, like FileAssets
  DatasetsController.solr_search_params_logic += [:exclude_unwanted_models]

  skip_before_filter :default_html_head

  # Catch permission errors
  rescue_from Hydra::AccessDenied, CanCan::AccessDenied do |exception|
    if exception.action == :edit
      #redirect_to action: 'show', alert: "You do not have sufficient privileges to edit this document"
      redirect_to action: 'show'
    elsif current_user and current_user.persisted?
      #redirect_to action: 'index', alert: exception.message
      redirect_to action: 'index'
    else
      session["user_return_to"] = request.url
      #redirect_to new_user_session_url, :alert => exception.message
      redirect_to new_user_session_url
    end
  end

  def index
    #@datasets = Dataset.all
    #Grab users recent documents
    recent_me_not_draft
    recent_me_draft
    @model = 'dataset'
  end

  def show
    authorize! :show, params[:id]
    @pid = params[:id]
    @files = contents
    @model = 'dataset'
  end

  def new
    @pid = Sufia::Noid.noidify(Sufia::IdService.mint)
    @pid = Sufia::Noid.namespaceize(@pid)
    @dataset = Dataset.new
    @model = 'dataset'
  end

  def edit
    authorize! :edit, params[:id]
    if @dataset.workflows.first.current_status != "Draft" && @dataset.workflows.first.current_status !=  "Referred"
       authorize! :review, params[:id]
    end
    @pid = params[:id]
    @files = contents
    @model = 'dataset'
  end

  def create
    @pid = params[:pid]
    @dataset = Dataset.find_or_create(@pid)
    @dataset.apply_permissions(current_user) 
    if params.has_key?(:files)
      create_from_upload(params)
    elsif params.has_key?(:dataset)
      if params[:dataset].has_key?(:workflows_attributes)
        add_workflow(params[:dataset])
      else
        add_metadata(params[:dataset])
      end
    else
      format.html { render action: 'edit' }
      format.json { render json: @dataset.errors, status: :unprocessable_entity }
    end

     #format.html { redirect_to action: 'show', id: @dataset.id }
     #format.json { render action: 'show', status: :created, location: @dataset }
  end

  def update
    @pid = params[:pid]
    if params.has_key?(:files)
      create_from_upload(params)
    elsif dataset_params
      if params[:dataset].has_key?(:workflows_attributes)
        add_workflow(params[:dataset])
      else
        add_metadata(params[:dataset])
      end
    else
      format.html { render action: 'edit' }
      format.json { render json: @dataset.errors, status: :unprocessable_entity }
    end
  end

  def destroy
    authorize! :destroy, params[:id]
    if @dataset.workflows.first.current_status != "Draft" && @dataset.workflows.first.current_status !=  "Referred"
       authorize! :review, params[:id]
    end
    @dataset.destroy
    respond_to do |format|
      format.html { redirect_to datasets_url }
      format.json { head :no_content }
    end
  end

  def datastream
    # To delete a datastream 
    @dataset.datasteams[dsid].delete
    parts = @dataset.hasPart
    @dataset.hasPart = nil
    @dataset.hasPart = parts.select { |key| not key.id.to_s.include? dsid }
    @dataset.save
  end

  def recent
    if user_signed_in?
      # grab other people's documents
      (_, @recent_documents) = get_search_results(:q =>filter_not_mine,
                                        :sort=>sort_field, :rows=>5)
    else 
      # grab any documents we do not know who you are
      (_, @recent_documents) = get_search_results(:q =>'', :sort=>sort_field, :rows=>5)
    end
  end

  def recent_me
    if user_signed_in?
      (_, @recent_user_documents) = get_search_results(:q =>filter_mine,
                                        :sort=>sort_field, :rows=>50, :fields=>"*:*")
    end
  end

  def recent_me_draft
    if user_signed_in?
      (_, @datasets) = get_search_results(:q =>filter_mine_draft,
                                        :sort=>sort_field, :rows=>50, :fields=>"*:*")
    end
  end

  def recent_me_not_draft
    if user_signed_in?
      (_, @submitted_datasets) = get_search_results(:q =>filter_mine_not_draft,
                                        :sort=>sort_field, :rows=>50, :fields=>"*:*")
    end
  end

  def self.uploaded_field
#  system_create_dtsi
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
    #elsif (!terms_accepted?)
    #  return json_error "You must accept the terms of service!", file.original_filename
    else
      process_file(file)
    end
  rescue => error
    logger.error "GenericFilesController::create rescued #{error.class}\n\t#{error.to_s}\n #{error.backtrace.join("\n")}\n\n"
    json_error "Error occurred while creating file."
  ensure
    # remove the tempfile (only if it is a temp file)
    file.tempfile.delete if file.respond_to?(:tempfile)
  end

  def process_file(file)
    #Sufia::GenericFile::Actions.create_content(@dataset, file, file.original_filename, datastream_id, current_user)
    @dataset.add_file(file, datastream_id, file.original_filename)
    save_tries = 0
    begin
      @dataset.save!
    rescue RSolr::Error::Http => error
      logger.warn "GenericFilesController::create_and_save_generic_file Caught RSOLR error #{error.inspect}"
      save_tries+=1
      # fail for good if the tries is greater than 3
      raise error if save_tries >=3
      sleep 0.01
      retry
    end

    respond_to do |format|
      format.html {
        render :json => [@dataset.to_jq_upload(file.original_filename, file.size, @dataset.id, datastream_id)],
        :content_type => 'text/html',
        :layout => false
      }
      format.json {
        render :json => [@dataset.to_jq_upload(file.original_filename, file.size, @dataset.id, datastream_id)]
      }
    end
  rescue ActiveFedora::RecordInvalid => af
    flash[:error] = af.message
    json_error "Error creating generic file: #{af.message}"
  end

  def add_workflow(dataset_params)
    @dataset.attributes = Ora.validateWorkflow(dataset_params)
    respond_to do |format|
      if @dataset.save
        format.html { redirect_to dataset_path(@dataset), notice: 'Dataset was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @dataset.errors, status: :unprocessable_entity }
      end
    end
  end

  def revoke_permissions
    if params.has_key?(:dataset) && params[:dataset].has_key?(:permissions_attributes)
      dataset_params = Ora.validatePermissionsToRevoke(params[:dataset], @dataset.workflowMetadata.depositor[0])
      respond_to do |format|
        if @dataset.update(dataset_params)
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

  def add_metadata(dataset_params)
    @dataset = Ora.buildMetadata(dataset_params, @dataset, contents)
    respond_to do |format|
      if @dataset.save
        format.html { redirect_to edit_dataset_path(@dataset), notice: 'Dataset was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @dataset.errors, status: :unprocessable_entity }
      end
    end
  end

  def contents
    choicesUsed = @dataset.datastreams.keys.select { |key| key.match(/^content\d+/) and @dataset.datastreams[key].content != nil }
    files = []
    for dsid in choicesUsed
      files.push(@dataset.to_jq_upload(@dataset.datastreams[dsid].label, @dataset.datastreams[dsid].size, @dataset.id, dsid))
    end
    files
  end

  def datastream_id
    choicesUsed = @dataset.datastreams.keys.select { |key| key.match(/^content\d+/) and @dataset.datastreams[key].content != nil }
    begin
      "content%02d"%(choicesUsed[-1].last(2).to_i+1)
    rescue
      "content01"
    end
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
  #  #Hydra.config[:permissions][:owner] maybe it should match this config variable, but it doesn't.
    Solrizer.solr_name('depositor', :stored_searchable, type: :string)
  end

  def workflow_status
  #  #Hydra.config[:permissions][:owner] maybe it should match this config variable, but it doesn't.
    Solrizer.solr_name('all_workflow_statuses', :stored_searchable, type: :symbol)
  end

  def filter_not_mine 
    "{!lucene q.op=AND df=#{depositor}}-#{current_user.user_key}"
  end

  def filter_mine
    "{!lucene q.op=AND df=#{depositor}}#{current_user.user_key}"
  end

  def filter_mine_draft
    "{!lucene q.op=AND} #{depositor}:#{current_user.user_key} #{workflow_status}:Draft"
  end

  def filter_mine_not_draft
    "{!lucene q.op=AND} #{depositor}:#{current_user.user_key} -#{workflow_status}:Draft"
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
