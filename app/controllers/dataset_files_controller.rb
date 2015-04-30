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
    opts = @dataset.datastream_opts(params[:dsid])
    if !opts.empty? && opts['dsLocation'].include?('/data/') && File.exist?(opts['dsLocation']) 
      send_file opts['dsLocation'], :type => opts['mimeType']
    else 
      render :status => 404
    end
  end

  def destroy
    authorize! :destroy, params[:id]
    if @dataset.workflows.first.current_status != "Draft" && @dataset.workflows.first.current_status !=  "Referred"
       authorize! :review, params[:id]
    end
    if @dataset.datastreams.keys.include?(params[:dsid])
      opts =  @dataset.datastream_opts(params[:dsid])
      @dataset.delete_file(opts['dsLocation'])
      @dataset.datastreams[params[:dsid]].delete
      parts = @dataset.hasPart
      @dataset.hasPart = nil
      @dataset.hasPart = parts.select { |key| not key.id.to_s.include? params[:dsid] }
      @dataset.adminDigitalSize = Integer(@dataset.adminDigitalSize.first) - Integer(opts['size']) rescue @dataset.adminDigitalSize
      @dataset.save
    end
    respond_to do |format|
      format.html { redirect_to dataset_url }
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
