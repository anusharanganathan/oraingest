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

require "ora/databank"
require "open-uri"

class DatasetFilesController < ApplicationController
  before_action :set_dataset, only: [:show, :destroy]

  # These before_filters apply the hydra access controls
  #before_filter :enforce_show_permissions, :only=>:show
  before_filter :authenticate_user!
  before_filter :has_access?

  skip_before_filter :default_html_head

  # Catch permission errors
  rescue_from Hydra::AccessDenied, CanCan::AccessDenied do |exception|
    if exception.action != :show
      redirect_to action: 'show', alert: "You do not have sufficient privileges to delete this file"
      #redirect_to action: 'show'
    elsif exception.action == :show
      redirect_to action: datasets_path, alert: "You do not have sufficient privileges to view or download this file"
    elsif current_user and current_user.persisted?
      redirect_to action: datasets_path, alert: exception.message
    else
      session["user_return_to"] = request.url
      redirect_to new_user_session_url, :alert => exception.message
    end
  end

  def show
    authorize! :show, params[:id]
    location = @dataset.file_location(params[:dsid])
    opts = @dataset.datastream_opts(params[:dsid])
    if @dataset.is_on_disk?(location)
      send_file location, :type => opts['mimeType']
    elsif @dataset.is_url?(location)
      begin
        timeout(10) { @stream = open(location, :http_basic_authentication=>[Sufia.config.databank_credentials['username'], Sufia.config.databank_credentials['password']]) }
      rescue
        render :status => 502
      end
      if @stream.status[0].to_i < 200 || @stream.status[0].to_i > 299 
        render :status => @stream.status[0].to_i
      end
      @file = Tempfile.new(opts['dsLabel'], 'tmp/files/')
      @file.binmode
      @file.write(@stream.read)
      @file.close
      send_file( @file.path, :filename => opts['dsLabel'] )
    else 
      render :status => 404
    end
  end

  def destroy
    authorize! :destroy, params[:id]
    unless Sufia.config.user_edit_status.include?(@dataset.workflows.first.current_status)
      authorize! :review, params[:id]
    end
    if @dataset.datastreams.keys.include?(params[:dsid])
      @dataset.delete_content(params[:dsid])
      # Save the dataset
      save_tries = 0
      begin
        @dataset.save!
      rescue RSolr::Error::Http => error
        logger.warn "DatasetFilesController::destroy caught error #{error.inspect}"
        save_tries+=1
        # fail for good if the tries is greater than 3
        raise error if save_tries >=3
        sleep 0.01
        retry
      end
    else
      render :status => 404
    end
    respond_to do |format|
      format.html { redirect_to edit_dataset_path(@dataset), notice: 'File was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private
  def set_dataset
    @dataset = Dataset.find(params[:id])
  end

  protected

  def depositor
    #Hydra.config[:permissions][:owner] maybe it should match this config variable, but it doesn't.
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

end
