# encoding: UTF-8
class ThesisFilesController < ApplicationController
  before_action :set_thesis, only: [:destroy]

  include Hydra::Controller::DownloadBehavior

  before_action :authenticate_user!
  before_action :has_access?

  skip_before_action :default_html_head

  # Catch permission errors
  rescue_from Hydra::AccessDenied, CanCan::AccessDenied do |exception|
    if exception.action != :show
      redirect_to action: 'show', alert: "You do not have sufficient privileges to delete this file"
    elsif exception.action == :show
      redirect_to action: theses_path, alert: "You do not have sufficient privileges to view or download this file"
    elsif current_user and current_user.persisted?
      redirect_to action: theses_path, alert: exception.message
    else
      session["user_return_to"] = request.url
      redirect_to new_user_session_url, :alert => exception.message
    end
  end

  def show
    authorize! :show, params[:id]
    send_content(asset)
  end

  def destroy
    authorize! :destroy, params[:id]
    if @thesis.workflows.first.current_status != "Draft" && @thesis.workflows.first.current_status !=  "Referred"
      authorize! :review, params[:id]
    end
    if @thesis.datastreams.keys.include?(params[:dsid])
      # To delete a datastream
      @thesis.datastreams[params[:dsid]].delete
      parts = @thesis.hasPart
      @thesis.hasPart = nil
      @thesis.hasPart = parts.select { |val| not val.id.to_s.include? params[:dsid] }
      @thesis.save
    end
    respond_to do |format|
      format.html { redirect_to edit_thesis_path(@thesis) }
      format.json { head :no_content }
    end
  end

  protected

  def depositor
    #  #Hydra.config[:permissions][:owner] maybe it should match this config variable, but it doesn't.
    Solrizer.solr_name('depositor', :stored_searchable, type: :string)
  end

  def has_access?
    true
  end

  def json_error(error, name=nil, additional_arguments={})
    args = {:error => error}
    args[:name] = name if name
    #render additional_arguments.merge({:json => [args]})
  end

  def datastream_to_show
    ds = asset.datastreams[params[:dsid]] if params.has_key?(:dsid)
    raise "Unable to find a datastream for #{asset}" if ds.nil?
    ds
  end

  private

  def set_thesis
    @thesis = Thesis.find(params[:id])
  end

end