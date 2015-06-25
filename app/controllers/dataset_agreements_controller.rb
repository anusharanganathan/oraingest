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

class DatasetAgreementsController < ApplicationController
  before_action :set_dataset_agreement, only: [:show, :edit, :update, :destroy]
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

  # These before_filters apply the hydra access controls
  #before_filter :enforce_show_permissions, :only=>:show
  before_filter :authenticate_user!, :except => [:show, :citation]
  before_filter :has_access?
  # This applies appropriate access controls to all solr queries
  DatasetAgreementsController.solr_search_params_logic += [:add_access_controls_to_solr_params]
  # This filters out objects that you want to exclude from search results, like FileAssets
  DatasetAgreementsController.solr_search_params_logic += [:exclude_unwanted_models]

  skip_before_filter :default_html_head

  # Catch permission errors
  rescue_from Hydra::AccessDenied, CanCan::AccessDenied do |exception|
    if exception.action != :show && exception.action != :index
      redirect_to action: 'show', alert: "You do not have sufficient privileges to modify this agreement record"
    elsif exception.action == :show
      redirect_to action: 'index', alert: "You do not have sufficient privileges to view this agreement record"
    elsif current_user and current_user.persisted?
      redirect_to action: 'index', alert: exception.message
      #redirect_to action: 'index'
    else
      session["user_return_to"] = request.url
      redirect_to new_user_session_url, :alert => exception.message
      #redirect_to new_user_session_url
    end
  end

  def index
    #@datasets = DatasetAgreement.all
    #Grab users recent documents
    recent
    recent_me
    relevant
    @model = 'dataset_agreement'
  end

  def show
    authorize! :show, params[:id]
    @pid = params[:id]
    @files = contents
    @model = 'dataset_agreement'
  end

  def new
    @pid = Sufia::Noid.noidify(SecureRandom.uuid)
    @pid = Sufia::Noid.namespaceize(@pid)
    @dataset_agreement = DatasetAgreement.new
    @model = 'dataset_agreement'
  end

  def edit
    authorize! :edit, params[:id]
    @pid = params[:id]
    @files = contents
    @model = 'dataset_agreement'
  end

  def create
    @pid = params[:pid]
    @dataset_agreement = DatasetAgreement.find_or_create(@pid)
    @dataset_agreement.apply_permissions(current_user) 
    if params.has_key?(:files)
      create_from_upload(params)
    elsif params.has_key?(:dataset_agreement)
      add_metadata(params[:dataset_agreement])
    else
      format.html { render action: 'edit' }
      format.json { render json: @dataset_agreement.errors, status: :unprocessable_entity }
    end

     #format.html { redirect_to action: 'show', id: @dataset_agreement.id }
     #format.json { render action: 'show', status: :created, location: @dataset_agreement }
  end

  def update
    @pid = params[:pid]
    if params.has_key?(:files)
      create_from_upload(params)
    elsif dataset_agreement_params
      add_metadata(params[:dataset_agreement])
    else
      format.html { render action: 'edit' }
      format.json { render json: @dataset_agreement.errors, status: :unprocessable_entity }
    end
  end

  def destroy
    authorize! :destroy, params[:id]
    @dataset_agreement.destroy
    respond_to do |format|
      format.html { redirect_to dataset_agreements_url }
      format.json { head :no_content }
    end
  end

  def datastream
    # To delete a datastream 
    @dataset_agreement.datasteams[dsid].delete
    parts = @dataset_agreement.hasPart
    @dataset_agreement.hasPart = nil
    @dataset_agreement.hasPart = parts.select { |key| not key.id.to_s.include? dsid }
    @dataset_agreement.save
  end

  def recent
    if user_signed_in?
      # grab other people's documents
      (_, @agreements) = get_search_results(:q =>filter_not_mine,
                                        :sort=>sort_field, :rows=>50)
    end
  end

  def recent_me
    if user_signed_in?
      (_, @user_agreements) = get_search_results(:q =>filter_mine,
                                        :sort=>sort_field, :rows=>50, :fields=>"*:*")
    end
  end

  def relevant
    if user_signed_in?
      (_, @relevant_user_agreements) = get_search_results(:q =>filter_relevant,
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
    #Sufia::GenericFile::Actions.create_content(@dataset_agreement, file, file.original_filename, datastream_id, current_user)
    current_title = @dataset_agreement.title
    @dataset_agreement.add_file(file, datastream_id, file.original_filename)
    # Do not replace title with filename when empty
    unless @dataset_agreement.title == current_title
      @dataset_agreement.title = current_title
    end
    save_tries = 0
    begin
      @dataset_agreement.save!
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
        render :json => [@dataset_agreement.to_jq_upload(file.original_filename, file.size, @dataset_agreement.id, datastream_id)],
        :content_type => 'text/html',
        :layout => false
      }
      format.json {
        render :json => [@dataset_agreement.to_jq_upload(file.original_filename, file.size, @dataset_agreement.id, datastream_id)]
      }
    end
  rescue ActiveFedora::RecordInvalid => af
    flash[:error] = af.message
    json_error "Error creating generic file: #{af.message}"
  end

  def add_metadata(dataset_agreement_params)
    #TODO: All data stewards should be added to list of contibutors
    MetadataBuilder.new(@dataset_agreement).build(dataset_agreement_params, contents, current_user.user_key)
    respond_to do |format|
      if @dataset_agreement.save
        format.html { redirect_to edit_dataset_agreement_path(@dataset_agreement), notice: 'Dataset agreement was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @dataset_agreement.errors, status: :unprocessable_entity }
      end
    end
  end

  def contents
    choicesUsed = @dataset_agreement.datastreams.keys.select { |key| key.match(/^content\d+/) and @dataset_agreement.datastreams[key].content != nil }
    files = []
    for dsid in choicesUsed
      files.push(@dataset_agreement.to_jq_upload(@dataset_agreement.datastreams[dsid].label, @dataset_agreement.datastreams[dsid].size, @dataset_agreement.id, dsid))
    end
    files
  end

  def datastream_id
    choicesUsed = @dataset_agreement.datastreams.keys.select { |key| key.match(/^content\d+/) and @dataset_agreement.datastreams[key].content != nil }
    begin
      "content%02d"%(choicesUsed[-1].last(2).to_i+1)
    rescue
      "content01"
    end
  end

  private
    def dataset_agreement_params
    #  #params.require(:dataset_agreement).permit(:title, :subtitle, :description, :abstract, {:keyword => []}, :medium, :numPages, :pages, :publicationStatus, :reviewStatus, :language, :language_attributes, :workflows, :workflows_attributes, :permissions, :permissions_attributes, :subject, :scheme, :elementList, :externalAuthority, :topicElement_attributes, :topicElement, :scheme_attributes)
    #  params.require(:dataset_agreement).permit!
    params.require(:dataset_agreement)
    end

  def set_dataset_agreement
    @dataset_agreement = DatasetAgreement.find(params[:id])
  end

  protected

  # Limits search results just to GenericFiles
  # @param solr_parameters the current solr parameters
  # @param user_parameters the current user-subitted parameters

  def exclude_unwanted_models(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "#{Solrizer.solr_name("has_model", :symbol)}:\"info:fedora/afmodel:DatasetAgreement\""
  end

  def depositor
  #  #Hydra.config[:permissions][:owner] maybe it should match this config variable, but it doesn't.
    Solrizer.solr_name('edit_access_person', :symbol, type: :string)
  end

  def filter_not_mine 
    "{!lucene q.op=AND df=#{depositor}}-#{current_user.user_key}"
  end

  def filter_mine
    "{!lucene q.op=AND df=#{depositor}}#{current_user.user_key}"
  end

  def filter_relevant
    "{!lucene q.op=AND df=#{Solrizer.solr_name("desc_metadata__contributor", :stored_searchable)}}#{current_user.user_key} -#{depositor}:#{current_user.user_key}"
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
