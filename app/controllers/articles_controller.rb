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
require "vocabulary/frapo"

class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy, :revokePermissions]
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
  ArticlesController.solr_search_params_logic += [:add_access_controls_to_solr_params]
  # This filters out objects that you want to exclude from search results, like FileAssets
  ArticlesController.solr_search_params_logic += [:exclude_unwanted_models]

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
    #@articles = Article.all
    #Grab users recent documents
    recent_me_not_draft
    recent_me_draft
  end

  def show
    authorize! :show, params[:id]
    @pid = params[:id]
    @files = contents
  end

  def new
    @pid = Sufia::Noid.noidify(Sufia::IdService.mint)
    @pid = Sufia::Noid.namespaceize(@pid)
    @article = Article.new
  end

  def edit
    authorize! :edit, params[:id]
    if @article.workflows.first.current_status != "Draft" && @article.workflows.first.current_status !=  "Referred"
       authorize! :review, params[:id]
    end
    @pid = params[:id]
    @files = contents
  end

  def create
    @pid = params[:pid]
    @article = Article.find_or_create(@pid)
    @article.apply_permissions(current_user) 
    if params.has_key?(:files)
      create_from_upload(params)
    elsif params.has_key?(:article)
      if params[:article].has_key?(:workflows_attributes)
        add_workflow(article_params)
      else
        add_metadata(article_params)
      end
    else
      format.html { render action: 'edit' }
      format.json { render json: @article.errors, status: :unprocessable_entity }
    end

     #format.html { redirect_to action: 'show', id: @article.id }
     #format.json { render action: 'show', status: :created, location: @article }
  end

  def update
    @pid = params[:pid]
    if params.has_key?(:files)
      create_from_upload(params)
    elsif article_params
      if params[:article].has_key?(:workflows_attributes)
        add_workflow(article_params)
      else
        add_metadata(article_params)
      end
    else
      format.html { render action: 'edit' }
      format.json { render json: @article.errors, status: :unprocessable_entity }
    end
  end

  def destroy
    authorize! :destroy, params[:id]
    if @article.workflows.first.current_status != "Draft" && @article.workflows.first.current_status !=  "Referred"
       authorize! :review, params[:id]
    end
    @article.destroy
    respond_to do |format|
      format.html { redirect_to articles_url }
      format.json { head :no_content }
    end
  end

  def datastream
    # To delete a datastream 
    @article.datasteams[dsid].delete
    parts = @article.hasPart
    @article.hasPart = nil
    @article.hasPart = parts.select { |key| not key.id.to_s.include? dsid }
    @article.save
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

  def add_workflow(article_params)
    article_params[:workflows_attributes] = [article_params[:workflows_attributes]]
    if article_params[:workflows_attributes][0].has_key?(:entries_attributes)
      article_params[:workflows_attributes][0][:entries_attributes] = [article_params[:workflows_attributes][0][:entries_attributes]]
    end
    if article_params[:workflows_attributes][0].has_key?(:comments_attributes)
      article_params[:workflows_attributes][0][:comments_attributes] = [article_params[:workflows_attributes][0][:comments_attributes]]
    end
    @article.attributes = article_params

    respond_to do |format|
      if @article.save
        format.html { redirect_to article_path(@article), notice: 'Article was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end

  end

  def revokePermissions
    if article_params.has_key? 'permissions_attributes'
      article_params['permissions_attributes'].each do |p|
        if p["type"].downcase != "group" && p["name"] != @article.workflowMetadata.depositor[0]
          if p.has_key? 'name' and !p["name"].empty? and p.has_key? 'access' and !p["access"].empty?
            p["type"] = "user"
            p["_destroy"] = true
          else
            article_params['permissions_attributes'].delete(p)
          end #check name and access exists
        else
          article_params['permissions_attributes'].delete(p)
        end # check not type = group and not depositor
      end # loop each permission
    end #has permission attributes
    respond_to do |format|
      if @article.update(article_params)
        format.html { redirect_to edit_article_path(@article), notice: 'Article was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  def add_metadata(article_params)
    if article_params.has_key?(:permissions_attributes)
      article_params[:permissions_attributes].each do |p|
        if p.has_key? 'name' and !p["name"].empty? and p.has_key? 'access' and !p["access"].empty?
          p["type"] = "user"
        else
          article_params['permissions_attributes'].delete(p)
        end #check name and access exists
      end 
    end
    @article.attributes = article_params

    #remove_blank_assertions for language and build
    if article_params.has_key?(:language)
      lp = article_params[:language]
      @article.language = nil
      if !lp[:languageLabel].empty?
        lp.each do |k, v| 
          lp[k] = nil if v.empty?
        end
        lp['id'] = "info:fedora/#{@article.id}#language"
        @article.language.build(lp)
      end
    end

    #remove_blank_assertions for subject and build
    if article_params.has_key?(:subject)
      sp = article_params[:subject]
      @article.subject = nil
      sp.each do |s|
        if s[:subjectLabel].empty?
           sp.delete(s)
        end
      end
      sp.each_with_index do |s, s_index|
        s.each do |k, v| 
          s[k] = nil if v.empty?
        end
        s['id'] = "info:fedora/#{@article.id}#subject#{s_index.to_s}"
        @article.subject.build(s)
      end
    end

    # Remove blank assertions for worktype and build
    if article_params.has_key?(:worktype)
      tp = article_params[:worktype].except(:typeAuthority)
      @article.worktype = nil
      if !tp[:typeLabel].empty?
        if Sufia.config.article_type_authorities.include?(tp[:typeLabel])
          tp[:typeAuthority] = Sufia.config.article_type_authorities[tp[:typeLabel]]
        end
        tp['id'] = "info:fedora/#{@article.id}#type"
        @article.worktype.build(tp)
      else
        tp[:typeLabel] = 'Article'
        tp[:typeAuthority] = Sufia.config.article_type_authorities["Article"]
        tp['id'] = "info:fedora/#{@article.id}#type"
        @article.worktype.build(tp)
      end
    end

    # Remove blank assertions for rights activity and build
    ag = []
    if article_params.has_key?(:license)
      lsp = article_params[:license].except(:licenseURI)
      @article.license = nil
      @article.rightsActivity = nil
      if !lsp[:licenseLabel].empty? or !lsp[:licenseStatement].empty?
        if Sufia.config.article_license_urls.include?(lsp[:licenseLabel])
          lsp[:licenseURI] = Sufia.config.article_license_urls[lsp[:licenseLabel]]
        elsif isURI(lsp[:licenseStatement])
          lsp[:licenseURI] = lsp[:licenseStatement]
          lsp[:licenseStatement] = nil
        end
        lsp['id'] = "info:fedora/#{@article.id}#license"
        lsp.each do |k, v|
          lsp[k] = nil if v.empty?
        end 
        @article.license.build(lsp)
        ag.push("info:fedora/#{@article.id}#license")
      end
    end
    if article_params.has_key?(:rights)
      rp = article_params[:rights].except(:rightsType)
      @article.rights = nil
      @article.rightsActivity = nil
      if !rp[:rightsStatement].empty?
        rp.each do |k, v| 
          rp[k] = nil if v.empty?
        end
      end
      rp[:rightsType] = RDF::DC.RightsStatement
      rp['id'] = "info:fedora/#{@article.id}#rights"
      @article.rights.build(rp)
      ag.push("info:fedora/#{@article.id}#rights")
    end
    if !ag.empty?
      rap = {activityUsed: "info:fedora/#{@article.id}", "id" => "info:fedora/#{@article.id}#rightsActivity", activityType: RDF::PROV.Activity, activityGenerated: ag}
      @article.rightsActivity.build(rap)
    end
    
    # Remove blank assertions for article access rights and build
    if article_params.has_key?(:accessRights)
      ar = article_params[:accessRights][0]
      @article.accessRights = nil
      ar['id'] = "info:fedora/#{@article.id}#accessRights"
      ar.each do |k, v| 
        ar[k] = nil if v.empty?
      end
      if ar[:embargoStatus] == "Visible"
        ar[:embargoStart] = nil
        ar[:embargoEnd] = nil
        ar[:embargoRelease] = nil
      elsif ar[:embargoStatus] == "Not visible"
        ar[:embargoStart] = nil
        ar[:embargoEnd] = nil
        ar[:embargoRelease] = nil
      end
      @article.accessRights.build(ar)
    end

    # Remove blank assertions for internal relations and build
    if article_params.has_key?(:hasPart)
      hp = article_params[:hasPart]
      @article.hasPart = nil
      select = {}
      count = 0
      for ds in contents
        dsid = ds['url'].split("/")[-1]
        hp.each do |k, h|
          if h[:identifier] == dsid
            select = h
            select['id'] = "info:fedora/#{@article.id}/datastreams/#{dsid}"
          end
        end
        select.each do |k, v| 
          select[k] = nil if v.empty?
        end
        @article.hasPart.build(select) 
        @article.hasPart[count].accessRights = nil
        if select.has_key?(:accessRights)
          select[:accessRights][0]['id'] = "info:fedora/#{@article.id}/datastreams/#{dsid}#accessRights"
          if select[:accessRights][0][:embargoStatus] == "Visible"
            select[:accessRights][0][:embargoStart] = nil
            select[:accessRights][0][:embargoEnd] = nil
            select[:accessRights][0][:embargoRelease] = nil
          elsif select[:accessRights][0][:embargoStatus] == "Not visible"
            select[:accessRights][0][:embargoStart] = nil
            select[:accessRights][0][:embargoEnd] = nil
            select[:accessRights][0][:embargoRelease] = nil
          end
          @article.hasPart[count].accessRights.build(select[:accessRights][0])
        end
        count += 1
      end 
    end

    #remove_blank_assertions for external relations and build
    if article_params.has_key?(:qualifiedRelation)
      qr = article_params[:qualifiedRelation]
      @article.qualifiedRelation = nil
      influences = []
      @article.influence = nil
      qr.each_with_index do |rel, rel_index|
        rel.each do |k, v|
          qr[rel_index][k] = nil if v.empty?
        end
        tmp = rel.except(:relation)
        qr[rel_index][:entity] = tmp
      end
      qr.each_with_index do |rel, rel_index|
        if !rel[:relation].nil? and !rel[:entity].empty?
          influences.push(rel[:entity]['id'])
          rel['id'] = "info:fedora/%s#qualifiedRelation%d" % [@article.id, rel_index]
          @article.qualifiedRelation.build(rel)
          @article.qualifiedRelation[rel_index].entity = nil
          rel[:entity][:type] = RDF::PROV.Entity
          @article.qualifiedRelation[rel_index].entity.build(rel[:entity])
        end
      end
      #influences = @article.relationsMetadata.getInfluences
      @article.influence = influences
    end

    #remove_blank_assertions for funding activity and build
    if article_params.has_key?(:funding)
      fp = article_params[:funding]
      @article.funding = nil
      if fp[0]
        # has to have name of funder and whom the funder funds
        fp[0][:funder].each do |f|
          if f[:name].empty? and f[:funds].empty?
            fp[0][:funder].delete(f)
          else
            f.each do |k, v|
              f[k] = nil if v.empty?
            end
          end
        end  
        id0 = "info:fedora/%s#fundingActivity" % @article.id
        vals = {'id' => id0, :wasAssociatedWith=> []}
        (0..fp[0][:funder].length-1).each do |n|
          b1 = "info:fedora/%s#funder%d" % [@article.id, n]
          vals[:wasAssociatedWith].push(b1)
        end
        @article.funding.build(vals)
        awardCount = 0
        fp[0][:funder].each_with_index do |f1, f1_index|
          agent = { 'id' => "info:fedora/%s#funder%d" % [@article.id, f1_index], :name => f1[:name], :sameAs => f1[:sameAs], :type => FRAPO.FundingAgency }
          b2 = "info:fedora/%s#fundingAssociation%d" % [@article.id, f1_index]
          f1['id'] = b2
          f1[:role] = FRAPO.FundingAgency
          #TODO: Need to be more smart about these Ids. These assumptions are wrong
          if f1[:funds] == "Author"
            f1[:funds] = "info:fedora/#{params[:pid]}#creator1"
          elsif f1[:funds] == "Publication"
            funds = "info:fedora/#{params[:pid]}"
          elsif f1[:funds] == "Project"
            funds = "info:fedora/#{params[:pid]}#project1"
          end
          @article.funding[0].funder.build(f1)
          @article.funding[0].funder[f1_index].agent = nil
          @article.funding[0].funder[f1_index].agent.build(agent)
          @article.funding[0].funder[f1_index].awards = nil
          if f1[:awards]
            f1[:awards].each do |aw|
              if aw[:grantNumber]
                aw['id'] = "info:fedora/%s#fundingAward%d" % [@article.id, awardCount]
                @article.funding[0].funder[f1_index].awards.build(aw)
                awardCount += 1
              end
            end
          end
        end
      end
    end

    #remove_blank_assertions for creation activity and build
    if article_params.has_key?(:creation)
      cp = article_params[:creation]
      @article.creation = nil
      if cp[0]
        # has to have name of creator
        cp[0][:creator].each do |c|
          if c[:name].empty?
            cp[0][:creator].delete(c)
          else
            c.each do |k, v|
              c[k] = nil if v.empty?
            end
          end
        end  
        id0 = "info:fedora/%s#creationActivity" % @article.id
        vals = {'id' => id0, :wasAssociatedWith=> [], :type => RDF::PROV.Activity}
        (0..cp[0][:creator].length-1).each do |n|
          b1 = "info:fedora/%s#creator%d" % [@article.id, n]
          vals[:wasAssociatedWith].push(b1)
        end
        @article.creation.build(vals)
        affiliationCount = 0
        @article.creation[0].creator = nil
        cp[0][:creator].each_with_index do |c1, c1_index|
          b1 = "info:fedora/%s#creator%d" % [@article.id, c1_index]
          agent = { 'id'=> b1, :name => c1[:name], :email => c1[:email], :type => RDF::VCARD.Individual, :sameAs => c1[:sameAs] }
          b2 = "info:fedora/%s#creationAssociation%d" % [@article.id, c1_index]
          c1['id'] = b2
          #c1[:agent] = b1
          c1[:type] = RDF::PROV.Association
          @article.creation[0].creator.build(c1)
          @article.creation[0].creator[c1_index].agent = nil
          @article.creation[0].creator[c1_index].agent.build(agent)
          @article.creation[0].creator[c1_index].agent[0].affiliation = nil
          if c1[:affiliation]
            c1[:affiliation].each do |af|
              if af[:name]
                af['id'] = "info:fedora/%s#affiliation%d" % [@article.id, affiliationCount]
                @article.creation[0].creator[c1_index].agent[0].affiliation.build(af)
                affiliationCount += 1
              end
            end
          end
        end
      end
    end

    #remove_blank_assertions for publication activity and build
    if article_params.has_key?(:publication)
      p = article_params[:publication]
      @article.publication = nil
      if !p.empty?
        p[0].each do |k, v|
          p[0][k] = nil if v.empty?
        end
        id0 = "info:fedora/%s#publicationActivity" % @article.id
        p[0]['id'] = id0
        p[0][:type] = RDF::PROV.Activity
        if !p[0][:publisher][0][:name].empty?
          p[0][:wasAssociatedWith] = ["info:fedora/%s#publisher" % @article.id]
        end
        @article.publication.build(p[0])
        @article.publication[0].hasDocument = nil
        if !p[0][:hasDocument].empty?
          if (p[0]["hasDocument"][0].except("journal").any? {|k,v| !v.nil? && !v.empty?} or \
              p[0]["hasDocument"][0]["journal"][0].except("periodical").any? {|k,v| !v.nil? && !v.empty?} or \
              p[0]["hasDocument"][0]["journal"][0]["periodical"][0].any? {|k,v| !v.nil? && !v.empty?})
            p[0][:hasDocument][0]['id'] = "info:fedora/%s#publicationDocument" % @article.id
            @article.publication[0].hasDocument.build(p[0][:hasDocument][0])
            @article.publication[0].hasDocument[0].journal = nil
            if (p[0]["hasDocument"][0]["journal"][0].except("periodical").any? {|k,v| !v.nil? && !v.empty?} or \
               p[0]["hasDocument"][0]["journal"][0]["periodical"][0].any? {|k,v| !v.nil? && !v.empty?})
               p[0][:hasDocument][0][:journal][0]['id'] = "info:fedora/%s#publicationJournal" % @article.id
              @article.publication[0].hasDocument[0].journal.build(p[0][:hasDocument][0][:journal][0])
              @article.publication[0].hasDocument[0].journal[0].periodical = nil
              p[0][:hasDocument][0][:journal][0][:periodical][0].each do |k, v|
                p[0][:hasDocument][0][:journal][0][:periodical][0][k] = nil if v.empty?
              end
              if p[0]["hasDocument"][0]["journal"][0]["periodical"][0].any? {|k,v| !v.nil? && !v.empty?}
                p[0][:hasDocument][0][:journal][0][:periodical][0]['id'] = "info:fedora/%s#publicationPeriodical" % @article.id
                @article.publication[0].hasDocument[0].journal[0].periodical.build(p[0][:hasDocument][0][:journal][0][:periodical][0])
              end
            end
          end
        end
        @article.publication[0].publisher = nil
        if !p[0][:publisher].empty?
          p[0][:publisher][0].each do |k, v|
            p[0][:publisher][0][k] = nil if v.empty?
          end
          if !p[0][:publisher][0][:name].nil?
            p[0][:publisher][0]['id'] = "info:fedora/%s#publicationAssociation" % @article.id
            p[0][:publisher][0][:type] = RDF::PROV.Association
            p[0][:publisher][0][:agent] = "info:fedora/%s#publisher" % @article.id
            p[0][:publisher][0][:role] = RDF::DC.publisher
            @article.publication[0].publisher.build(p[0][:publisher][0])
          end
        end  
      end
    end

    respond_to do |format|
      if @article.save
        format.html { redirect_to edit_article_path(@article), notice: 'Article was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  def contents
    choicesUsed = @article.datastreams.keys.select { |key| key.match(/^content\d+/) and @article.datastreams[key].content != nil }
    files = []
    for dsid in choicesUsed
      files.push(@article.to_jq_upload(@article.datastreams[dsid].label, @article.datastreams[dsid].size, @article.id, dsid))
    end
    files
  end

  def datastream_id
    choicesUsed = @article.datastreams.keys.select { |key| key.match(/^content\d+/) and @article.datastreams[key].content != nil }
    begin
      "content%02d"%(choicesUsed[-1].last(2).to_i+1)
    rescue
      "content01"
    end
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
