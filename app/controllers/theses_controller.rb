# encoding: UTF-8
class ThesesController < ApplicationController
  before_action :set_thesis, only: [:show, :edit, :update, :destroy]
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
  before_action :authenticate_user!, :except => [:show]
  before_action :has_access?
  # This applies appropriate access controls to all solr queries
  ThesesController.solr_search_params_logic += [:add_access_controls_to_solr_params]
  # This filters out objects that you want to exclude from search results, like FileAssets
  ThesesController.solr_search_params_logic += [:exclude_unwanted_models]

  skip_before_action :default_html_head

  rescue_from Hydra::AccessDenied, CanCan::AccessDenied do |exception|
    if exception.action != :show && exception.action != :index
      redirect_to action: 'show', alert: "You do not have sufficient privileges to modify this thesis record"
      #redirect_to action: 'show'
    elsif exception.action == :show
      redirect_to publications_path, alert: "You do not have sufficient privileges to read this thesis record"
    elsif current_user and current_user.persisted?
      redirect_to publications_path, alert: exception.message
    else
      session["user_return_to"] = request.url
      redirect_to new_user_session_url, :alert => exception.message
    end
  end

  def show
    authorize! :show, params[:id]
    @pid = params[:id]
    @files = contents
    @model = 'thesis'
  end

  def new
    @pid = Sufia::Noid.noidify(SecureRandom.uuid)
    @pid = Sufia::Noid.namespaceize(@pid)
    @thesis = Thesis.new
    @files = []
    @model = 'thesis'
  end

  def create
    @pid = params[:pid]
    @thesis = Thesis.find_or_create(@pid)
    @thesis.apply_permissions(current_user)
    if params.has_key?(:files)
      create_from_upload(params)
    elsif params.has_key?(:thesis)
      add_metadata(params[:thesis], "")
    else
      respond_to do |format|
        format.html { render action: 'edit' }
        format.json { render json: @thesis.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    authorize! :edit, params[:id]
    unless Sufia.config.next_workflow_status.keys.include?(@thesis.workflows.first.current_status)
      raise CanCan::AccessDenied.new("Not authorized to edit while record is being migrated!", :read, Thesis)
    end
    if @thesis.workflows.first.current_status != "Draft" && @thesis.workflows.first.current_status !=  "Referred"
      authorize! :review, params[:id]
    end
    @pid = params[:id]
    @files = contents
    @model = 'thesis'
  end

  def update
    @pid = params[:pid]
    redirect_field = ""
    if params.has_key?(:redirect_field)
      redirect_field = params[:redirect_field]
    end
    if params.has_key?(:files)
      create_from_upload(params)
    elsif thesis_params
      add_metadata(params[:thesis], redirect_field)
    else
      respond_to do |format|
        format.html { render action: 'edit' }
        format.json { render json: @thesis.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize! :destroy, params[:id]
    unless Sufia.config.next_workflow_status.keys.include?(@thesis.workflows.first.current_status)
      raise CanCan::AccessDenied.new("Not authorized to delete while record is being migrated!", :read, Thesis)
    end
    if @thesis.workflows.first.current_status != "Draft" && @thesis.workflows.first.current_status !=  "Referred"
      authorize! :review, params[:id]
    end
    @thesis.destroy
    respond_to do |format|
      format.html { redirect_to publications_path }
      format.json { head :no_content }
    end
  end

  private

  def thesis_params
    params.require(:thesis)
  end

  def set_thesis
    @thesis = Thesis.find(params[:id])
  end

  # Limits search results just to GenericFiles
  # @param solr_parameters the current solr parameters
  # @param user_parameters the current user-subitted parameters
  def exclude_unwanted_models(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "#{Solrizer.solr_name("has_model", :symbol)}:\"info:fedora/afmodel:Thesis\""
  end

  def contents
    content_datastreams = @thesis.datastreams.keys.select { |key| key.match(/^content\d+/) and @thesis.datastreams[key].content != nil }
    files = []
    content_datastreams.each do |dsid|
      files.push(@thesis.to_jq_upload(@thesis.datastreams[dsid].label, @thesis.datastreams[dsid].size, @thesis.id, dsid))
    end
    files
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
    logger.error "ThesesController::create rescued #{error.class}\n\t#{error.to_s}\n #{error.backtrace.join("\n")}\n\n"
    json_error "Error occurred while creating file."
  ensure
    # remove the tempfile (only if it is a temp file)
    file.tempfile.delete if file.respond_to?(:tempfile)
  end

  def process_file(file)
    #Sufia::GenericFile::Actions.create_content(@thesis, file, file.original_filename, datastream_id, current_user)
    datastream_id = @thesis.mint_datastream_id()
    @thesis.add_file(file, datastream_id, file.original_filename)
    save_tries = 0
    begin
      @thesis.save!
    rescue RSolr::Error::Http => error
      logger.warn "ThesesController::create_and_save_generic_file Caught RSOLR error #{error.inspect}"
      save_tries+=1
      # fail for good if the tries is greater than 3
      raise error if save_tries >=3
      sleep 0.01
      retry
    end

    respond_to do |format|
      format.html {
        render :json => [@thesis.to_jq_upload(file.original_filename, file.size, @thesis.id, datastream_id)],
               :content_type => 'text/html',
               :layout => false
      }
      format.json {
        render :json => [@thesis.to_jq_upload(file.original_filename, file.size, @thesis.id, datastream_id)]
      }
    end
  rescue ActiveFedora::RecordInvalid => af
    flash[:error] = af.message
    json_error "Error creating generic file: #{af.message}"
  end

  def add_metadata(thesis_params, redirect_field)
    if !@thesis.workflows.nil? && !@thesis.workflows.first.entries.nil?
      old_status = @thesis.workflows.first.current_status
    else
      old_status = nil
    end
    MetadataBuilder.new(@thesis).build(thesis_params, contents, current_user.user_key)
    if old_status != @thesis.workflows.first.current_status
      WorkflowPublisher.new(@thesis).perform_action(current_user.user_key)
    end
    respond_to do |format|
      if @thesis.save
        if can? :review, @thesis
          format.html { redirect_to edit_thesis_path(@thesis), notice: 'Thesis was successfully updated.', flash:{ redirect_field: redirect_field } }
          format.json { head :no_content }
        else
          format.html { redirect_to edit_thesis_path(@thesis), notice: 'Thesis was successfully updated.' }
          format.json { head :no_content }
        end
      else
        format.html { render action: 'edit' }
        format.json { render json: @thesis.errors, status: :unprocessable_entity }
      end
    end
  end

  def json_error(error, name=nil, additional_arguments={})
    args = {:error => error}
    args[:name] = name if name
  end

  def empty_file?(file)
    (file.respond_to?(:tempfile) && file.tempfile.size == 0) || (file.respond_to?(:size) && file.size == 0)
  end

end
