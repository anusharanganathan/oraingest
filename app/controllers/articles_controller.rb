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

class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :edit_detailed, :update, :destroy, :revoke_permissions]
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
  ArticlesController.solr_search_params_logic += [:add_access_controls_to_solr_params]
  # This filters out objects that you want to exclude from search results, like FileAssets
  ArticlesController.solr_search_params_logic += [:exclude_unwanted_models]

  skip_before_filter :default_html_head

  # Catch permission errors
  rescue_from Hydra::AccessDenied, CanCan::AccessDenied do |exception|
    if exception.action != :show && exception.action != :index
      redirect_to action: 'show', alert: "You do not have sufficient privileges to modify this publication record"
      #redirect_to action: 'show'
    elsif exception.action == :show
      redirect_to publications_path, alert: "You do not have sufficient privileges to read this publication record"
    elsif current_user and current_user.persisted?
      redirect_to publications_path, alert: exception.message
    else
      session["user_return_to"] = request.url
      redirect_to new_user_session_url, :alert => exception.message
      #redirect_to new_user_session_url
    end
  end

  def index
    redirect_to publications_path
  end

  def show
    authorize! :show, params[:id]
    @pid = params[:id]
    @files = contents
    @model = 'article'
  end

  def new
    @pid = Sufia::Noid.noidify(SecureRandom.uuid)
    @pid = Sufia::Noid.namespaceize(@pid)
    @article = Article.new
    @files = []
    @model = 'article'
  end

  def edit
    authorize! :edit, params[:id]
    unless Sufia.config.next_workflow_status.keys.include?(@article.workflows.first.current_status)
      raise CanCan::AccessDenied.new("Not authorized to edit while record is being migrated!", :read, Article)
    end
    unless Sufia.config.user_edit_status.include?(@article.workflows.first.current_status)
      authorize! :review, params[:id]
    end
    @pid = params[:id]
    @files = contents
    @model = 'article'
  end

  def edit_detailed
    authorize! :edit, params[:id]
    unless Sufia.config.next_workflow_status.keys.include?(@article.workflows.first.current_status)
      raise CanCan::AccessDenied.new("Not authorized to edit while record is being migrated!", :read, Article)
    end
    authorize! :review, params[:id]
    @pid = params[:id]
    @files = contents
    @model = 'article'
    render "edit_detailed"
  end

  def create
    @pid = params[:pid]
    @article = Article.find_or_create(@pid)
    @article.apply_permissions(current_user) 
    if params.has_key?(:files)
      create_from_upload(params)
    elsif params.has_key?(:article)
      add_metadata(params[:article], "")
    elsif can? :review, @article
      format.html { render action: 'edit_detailed' }
      format.json { render json: @article.errors, status: :unprocessable_entity }
    else
      format.html { render action: 'edit' }
      format.json { render json: @article.errors, status: :unprocessable_entity }
    end
  end

  def update
    @pid = params[:pid]
    redirect_field = ""
    if params.has_key?(:redirect_field)
      redirect_field = params[:redirect_field]
    end
    if params.has_key?(:files)
      create_from_upload(params)
    elsif article_params
      add_metadata(params[:article], redirect_field)
    elsif can? :review, @article
      format.html { render action: 'edit_detailed' }
      format.json { render json: @article.errors, status: :unprocessable_entity }
    else
      format.html { render action: 'edit' }
      format.json { render json: @article.errors, status: :unprocessable_entity }
    end
  end

  def destroy
    authorize! :destroy, params[:id]
    unless Sufia.config.next_workflow_status.keys.include?(@article.workflows.first.current_status)
      raise CanCan::AccessDenied.new("Not authorized to delete while record is being migrated!", :read, Article)
    end
    unless Sufia.config.user_edit_status.include?(@article.workflows.first.current_status)
       authorize! :review, params[:id]
    end
    @article.destroy
    respond_to do |format|
      format.html { redirect_to publications_path }
      format.json { head :no_content }
    end
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
      (_, @articles) = get_search_results(:q =>filter_mine_draft,
                                        :sort=>sort_field, :rows=>50, :fields=>"*:*")
    end
  end

  def recent_me_not_draft
    if user_signed_in?
      (_, @submitted_articles) = get_search_results(:q =>filter_mine_not_draft,
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
    #Sufia::GenericFile::Actions.create_content(@article, file, file.original_filename, datastream_id, current_user)
    datastream_id = @article.mint_datastream_id()
    @article.add_file(file, datastream_id, file.original_filename)
    save_tries = 0
    begin
      @article.save!
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
        render :json => [@article.to_jq_upload(file.original_filename, file.size, @article.id, datastream_id)],
        :content_type => 'text/html',
        :layout => false
      }
      format.json {
        render :json => [@article.to_jq_upload(file.original_filename, file.size, @article.id, datastream_id)]
      }
    end
  rescue ActiveFedora::RecordInvalid => af
    flash[:error] = af.message
    json_error "Error creating generic file: #{af.message}"
  end

  def revoke_permissions
    authorize! :destroy, params[:id]
    if params.has_key?(:access) && params.has_key?(:name) && params.has_key?(:type)
      new_params = MetadataBuilder.new(@article).validatePermissionsToRevoke(params, @article.workflowMetadata.depositor[0])
      respond_to do |format|
        if @article.update(new_params)
          if can? :review, @article
            format.html { redirect_to edit_detailed_articles_path(@article), notice: 'Article was successfully updated.' }
            format.json { head :no_content }
          else
            format.html { redirect_to edit_article_path(@article), notice: 'Article was successfully updated.' }
            format.json { head :no_content }
          end
        elsif can? :review, @article
          format.html { render action: 'edit_detailed' }
          format.json { render json: @article.errors, status: :unprocessable_entity }
        else
          format.html { render action: 'edit' }
          format.json { render json: @article.errors, status: :unprocessable_entity }
        end
      end
    elsif can? :review, @article
      format.html { render action: 'edit_detailed' }
      format.json { render json: @article.errors, status: :unprocessable_entity }
    else
      format.html { render action: 'edit' }
      format.json { render json: @article.errors, status: :unprocessable_entity }
    end
  end

  def add_metadata(article_params, redirect_field)
    if !@article.workflows.nil? && !@article.workflows.first.entries.nil?
      old_status = @article.workflows.first.current_status
    else
      old_status = nil
    end
    MetadataBuilder.new(@article).build(article_params, contents, current_user.user_key)
    if old_status != @article.workflows.first.current_status
      WorkflowPublisher.new(@article).perform_action(current_user)
    end
    respond_to do |format|
      if @article.save
        if can? :review, @article
          format.html { redirect_to edit_detailed_articles_path(@article), notice: 'Article was successfully updated.', flash:{ redirect_field: redirect_field } }
          format.json { head :no_content }
        else
          format.html { redirect_to edit_article_path(@article), notice: 'Article was successfully updated.' }
          format.json { head :no_content }
        end
      elsif can? :review, @article
        format.html { render action: 'edit_detailed' }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      else
        format.html { render action: 'edit' }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  def contents
    files = []
    @article.content_datastreams.each do |dsid|
      files.push(@article.to_jq_upload(@article.datastreams[dsid].label, @article.datastreams[dsid].size, @article.id, dsid))
    end
    files
  end

  private
    def article_params
    #  #params.require(:article).permit(:title, :subtitle, :description, :abstract, {:keyword => []}, :medium, :numPages, :pages, :publicationStatus, :reviewStatus, :language, :language_attributes, :workflows, :workflows_attributes, :permissions, :permissions_attributes, :subject, :scheme, :elementList, :externalAuthority, :topicElement_attributes, :topicElement, :scheme_attributes)
    #  params.require(:article).permit!
    params.require(:article)
    end

  def set_article
    @article = Article.find(params[:id])
  end

  protected

  # Limits search results just to GenericFiles
  # @param solr_parameters the current solr parameters
  # @param user_parameters the current user-subitted parameters

  def exclude_unwanted_models(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "#{Solrizer.solr_name("has_model", :symbol)}:\"info:fedora/afmodel:Article\""
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
    "{!lucene q.op=AND} #{depositor}:#{current_user.user_key} #{workflow_status}:#{Sufia.config.draft_status}"
  end

  def filter_mine_not_draft
    "{!lucene q.op=AND} #{depositor}:#{current_user.user_key} -#{workflow_status}:#{Sufia.config.draft_status}"
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
