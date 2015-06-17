require 'vocabulary/ora'

class MetadataBuilder

  attr_accessor :model
  
  def initialize(model)
    @model = model
  end

  def build(params, contents, depositor)
    # Validate permissions
    if params.has_key?(:permissions_attributes)
      params[:permissions_attributes] = validatePermissions(params[:permissions_attributes])
    end
    if params.has_key?(:workflows_attributes)
      params[:workflows_attributes] = validateWorkflow(params[:workflows_attributes], depositor)
    end

    #remove_blank_assertions for language and build
    if params.has_key?(:language)
      buildLanguage(params[:language])
      params.except!(:language)
    end

    #remove_blank_assertions for subject and build
    if params.has_key?(:subject)
      buildSubject(params[:subject])
      params.except!(:subject)
    end

    # Remove blank assertions for worktype and build
    if params.has_key?(:worktype)
      buildWorktype(params[:worktype])
      params.except!(:worktype)
    end

    #Remove blank assertions for temporal coverage and build
    if params.has_key?(:temporal)
      buildTemporalData(params[:temporal])
      params.except!(:temporal)
    end

    #Remove blank assertions for date collected and build
    if params.has_key?(:dateCollected)
      buildDateCollected(params[:dateCollected])
      params.except!(:dateCollected)
    end

    #Remove blank assertions for spatial coverage and build
    if params.has_key?(:spatial)
      buildSpatialData(params[:spatial])
      params.except!(:spatial)
    end

    if params.has_key?(:storageAgreement)
      buildStorageAgreementData(params[:storageAgreement])
      params.except!(:storageAgreement)
    end

    #remove_blank_assertions for publication activity and build
    if params.has_key?(:publication)
      buildPublicationActivity(params[:publication])
      params.except!(:publication)
    end
    # get the publication date to calculate embargo dates for access rights
    if model.class.to_s != "DatasetAgreement"
      datePublished = nil
      if !model.publication[0].nil? && !model.publication[0].datePublished.nil?
        datePublished = model.publication[0].datePublished.first
      end
    end

    # Remove blank assertions for dataset access rights and build
    if params.has_key?(:accessRights)
      buildAccessRights(params[:accessRights], datePublished)
      params.except!(:accessRights)
    end

    # Remove blank assertions for internal relations and build
    if params.has_key?(:hasPart)
      buildInternalRelations(params[:hasPart], datePublished, contents)
      params.except!(:hasPart)
    end

    #remove_blank_assertions for external relations and build
    if params.has_key?(:qualifiedRelation)
      buildExternalRelations(params[:qualifiedRelation])
      params.except!(:qualifiedRelation)
    end

    #remove_blank_assertions for funding activity and build
    if params.has_key?(:funding)
      buildFundingActivity(params[:funding])
      params.except!(:funding)
    end

    #remove_blank_assertions for creation activity and build
    if params.has_key?(:creation)
      buildCreationActivity(params[:creation])
      params.except!(:creation)
    end

    #remove_blank_assertions for titular stewardship activity and build
    if params.has_key?(:titularActivity)
      buildTitularActivity(params[:titularActivity])
      params.except!(:titularActivity)
    end

    # Remove blank assertions for rights activity and build
    #NOTE: do this after building creation activity (need author roles)!!!
    if params.has_key?(:license) || params.has_key?(:rights)
      buildRightsActivity(params)
      params.except!(:license)
      params.except!(:rights)
    end

    #Remove blank assertions for validity date and build
    if params.has_key?(:valid)
      buildValidityDate(params[:valid])
      params.except!(:valid)
    end

    #Remove blank assertions for invoice details and build
    if params.has_key?(:invoice)
      buildInvoiceData(params[:invoice])
      params.except!(:invoice)
    end
    model.attributes = params
  end

  def normalizeParams(params)
    if params.kind_of?(Hash)# && (params.keys.include?("0") || params.keys.include?("info:fedora"))
      params = params.values
    end
    unless params.kind_of?(Array)
      params = [params]
    end
    params
  end

  def validatePermissions(params)
    permissions = []
    normalizeParams(params).each do |p|
      if p.has_key? 'name' and !p["name"].empty? and p.has_key? 'access' and !p["access"].empty?
        p["type"] = "user"
        permissions << p
      end #check name and access exists
    end
    permissions
  end

  def validatePermissionsToRevoke(params, depositor)
    newParams = {"permissions_attributes" => []}
    if params.has_key?("type") && !params["type"].empty? && params.has_key?("name") && !params["name"].empty? && params.has_key?("access") && !params["access"].empty?
      if params["type"].downcase != "group" && params["name"] != depositor
        p = {}
        p["type"] = "user"
        p["name"] = params["name"]
        p["access"] = params["access"]
        p["_destroy"] = true
        newParams['permissions_attributes'] << p
      end # check not type = group and not depositor
    end #check type, name and access exists
    newParams
  end

  def validateWorkflow(params, depositor)
    if params
      params = normalizeParams(params)

      if !model.workflows.nil? && model.workflows.first
        # Workflow needs to have same id. We are not creating a new workflow, but just an entry
        #TODO: Rather than assuming first workflow, select first workflow with identifier MediatedSubmission
        params[0][:id] = model.workflows.first.rdf_subject.to_s
      end
      if params[0].has_key?(:entries_attributes)
        # Validate entries is array
        params[0][:entries_attributes] = normalizeParams(params[0][:entries_attributes])
        if params[0][:entries_attributes][0][:status].nil? || params[0][:entries_attributes][0][:status].empty? || model.workflows.first.current_status == params[0][:entries_attributes][0][:status]
          params[0] = params[0].except(:entries_attributes)
        else
          # Set creator to user logged in
          params[0][:entries_attributes][0][:creator] = [depositor]
          params[0][:entries_attributes][0][:date] = [Time.now.to_s]
        end
      end
      if params[0].has_key?(:emailThreads_attributes)
        params[0][:emailThreads_attributes] = normalizeParams(params[0][:emailThreads_attributes])
      end
      if params[0].has_key?(:comments_attributes)
        params[0][:comments_attributes] = normalizeParams(params[0][:comments_attributes])
        # Add date and creator if not empty, else set to nil
        if params[0][:comments_attributes][0][:description].nil? || params[0][:comments_attributes][0][:description].empty?
          params[0] = params[0].except(:comments_attributes)
        else
          params[0][:comments_attributes][0][:date] = [Time.now.to_s]
          params[0][:comments_attributes][0][:creator] = [depositor]
        end
      end
    end
    params
  end

  def buildLanguage(params)
    #remove_blank_assertions for language and build
    model.language = nil
    if !params[:languageLabel].empty?
      params.each do |k, v|
        params[k] = nil if v.empty?
      end
      params['id'] = "info:fedora/#{model.id}#language"
      model.language.build(params)
    end
  end

  def buildSubject(params)
    model.subject = nil
    subjects = []
    normalizeParams(params).each do |s|
      if !s[:subjectLabel].empty?
        subjects << s
      end
    end
    subjects.each_with_index do |s, s_index|
      s.each do |k, v|
        s[k] = nil if v.empty?
      end
      s['id'] = "info:fedora/#{model.id}#subject#{s_index.to_s}"
      model.subject.build(s)
    end
  end

  def buildWorktype(params)
    params = params.except(:typeAuthority)
    model.worktype = nil
    if !params[:typeLabel].empty?
      if Sufia.config.type_authorities[model.model_klass.downcase].include?(params[:typeLabel])
        params[:typeAuthority] = Sufia.config.type_authorities[model.model_klass.downcase][params[:typeLabel]]
      end
      params['id'] = "info:fedora/#{model.id}#type"
      model.worktype.build(params)
    else
      params[:typeLabel] = model.model_klass
      params[:typeAuthority] = Sufia.config.type_authorities[model.model_klass.downcase][model.model_klass]
      params['id'] = "info:fedora/#{model.id}#type"
      model.worktype.build(params)
    end
  end

  def buildRightsActivity(params)
    ag = []
    model.rightsActivity = nil
    if params.has_key?(:license)
      lsp = params[:license].except(:licenseURI)
      model.license = nil
      if !lsp[:licenseLabel].empty? or !lsp[:licenseStatement].empty?
        if Sufia.config.license_urls.include?(lsp[:licenseLabel])
          lsp[:licenseURI] = Sufia.config.license_urls[lsp[:licenseLabel]]
        elsif isURI(lsp[:licenseStatement])
          lsp[:licenseURI] = lsp[:licenseStatement]
          lsp[:licenseStatement] = nil
        end
        lsp['id'] = "info:fedora/#{model.id}#license"
        lsp.each do |k, v|
          lsp[k] = nil if v.empty?
        end
        model.license.build(lsp)
        ag.push("info:fedora/#{model.id}#license")
      end
    end
    if model.creation.first && model.creation.first.creator
      unless params.has_key?(:rightsHolder)
        params[:rightsHolder] = []
      end
      model.creation[0].creator.each do |creator|
        if creator.role.any? and creator.role.include?(RDF::ORA.copyrightHolder)
          params[:rightsHolder].push(creator.agent.first.id)
        end
      end
    end
    if params.has_key?(:rights)
      rp = params[:rights].except(:rightsType)
      model.rights = nil
      if !rp[:rightsStatement].empty?
        rp.each do |k, v|
          rp[k] = nil if v.empty?
        end
      end
      rp[:rightsType] = RDF::DC.RightsStatement
      rp['id'] = "info:fedora/#{model.id}#rights"
      model.rights.build(rp)
      ag.push("info:fedora/#{model.id}#rights")
    end
    if !ag.empty?
      rap = {activityUsed: "info:fedora/#{model.id}", "id" => "info:fedora/#{model.id}#rightsActivity", activityType: RDF::PROV.Activity, activityGenerated: ag}
      model.rightsActivity.build(rap)
    end
  end

  def buildAccessRights(params, datePublished)
    params = validateEmbargoDates(params, "info:fedora/#{model.id}", datePublished)
    model.accessRights = nil
    model.accessRights.build(params)
    model.accessRights[0].embargoDate = nil
    if params[:embargoStatus] == "Embargoed"
      model.accessRights[0].embargoDate.build(params[:embargoDate][0])
      model.accessRights[0].embargoDate[0].start = nil
      model.accessRights[0].embargoDate[0].duration = nil
      model.accessRights[0].embargoDate[0].end = nil
      if !params[:embargoDate][0][:start].nil? && (!params[:embargoDate][0][:start][0][:label].nil? || !params[:embargoDate][0][:start][0][:date].nil?)
        model.accessRights[0].embargoDate[0].start.build(params[:embargoDate][0][:start][0])
      end
      if !params[:embargoDate][0][:duration].nil? && (!params[:embargoDate][0][:duration][0][:years].nil? || !params[:embargoDate][0][:duration][0][:months].nil?)
        model.accessRights[0].embargoDate[0].duration.build(params[:embargoDate][0][:duration][0])
      end
      if !params[:embargoDate][0][:end].nil? && (!params[:embargoDate][0][:end][0][:label].nil? || !params[:embargoDate][0][:end][0][:date].nil?)
        model.accessRights[0].embargoDate[0].end.build(params[:embargoDate][0][:end][0])
      end
    end
  end

  def buildInternalRelations(params, datePublished, contents)
    model.hasPart = nil
    select = {}
    count = 0
    for ds in contents
      dsid = ds['url'].split("/")[-1]
      params.each do |k, h|
        if h[:identifier] == dsid
          select = h
          select['id'] = "info:fedora/#{model.id}/datastreams/#{dsid}"
        end
      end
      select.each do |k, v|
        select[k] = nil if v.nil? || v.empty?
      end
      model.hasPart.build(select)
      model.hasPart[count].accessRights = nil
      endDate = nil
      if select.has_key?(:accessRights)
        ar = validateEmbargoDates(select[:accessRights], "info:fedora/#{model.id}/datastreams/#{dsid}", datePublished)
        model.hasPart[count].accessRights.build(ar)
        model.hasPart[count].accessRights[0].embargoDate = nil
        if ar[:embargoStatus] == "Embargoed"
          model.hasPart[count].accessRights[0].embargoDate.build(ar[:embargoDate][0])
          model.hasPart[count].accessRights[0].embargoDate[0].start = nil
          model.hasPart[count].accessRights[0].embargoDate[0].duration = nil
          model.hasPart[count].accessRights[0].embargoDate[0].end = nil
          if !ar[:embargoDate][0][:start].nil? && (!ar[:embargoDate][0][:start][0][:label].nil? || !ar[:embargoDate][0][:start][0][:date].nil?)
            model.hasPart[count].accessRights[0].embargoDate[0].start.build(ar[:embargoDate][0][:start][0])
          end
          if !ar[:embargoDate][0][:duration].nil? && (!ar[:embargoDate][0][:duration][0][:years].nil? || !ar[:embargoDate][0][:duration][0][:months].nil?)
            model.hasPart[count].accessRights[0].embargoDate[0].duration.build(ar[:embargoDate][0][:duration][0])
          end
          if !ar[:embargoDate][0][:end].nil? && (!ar[:embargoDate][0][:end][0][:label].nil? || !ar[:embargoDate][0][:end][0][:date].nil?)
            model.hasPart[count].accessRights[0].embargoDate[0].end.build(ar[:embargoDate][0][:end][0])
          end
        end
      end
      count += 1
    end
  end

  def buildExternalRelations(params)
    extRelations = []
    params.values.each_with_index do |rel, rel_index|
      hasInfo = false
      rel[:entity_attributes]["0"].each do |k, v|
        if v.empty?
          rel[:entity_attributes]["0"][k] = nil
        else
          hasInfo = true
        end
      end
      if hasInfo && rel.has_key?(:relation) && !rel[:relation].nil? && !rel[:relation].empty?
        extRelations << rel
      end
    end
    model.qualifiedRelation = nil
    model.influence = nil
    influences = []
    extRelations.each_with_index do |rel, rel_index|
      if rel[:entity_attributes]["0"]['identifier'].nil? || rel[:entity_attributes]["0"]['identifier'].empty?
        rel[:entity_attributes]["0"]['id'] = "info:fedora/#{model.id}#externalRelation#{rel_index.to_s}"
      elsif rel[:entity_attributes]["0"]['identifier'].include?('10.')
        rel[:entity_attributes]["0"]['id'] = model.remote_uri_for(rel[:entity_attributes]["0"]['identifier'])
      elsif rel[:entity_attributes]["0"]['identifier'].start_with?('http')
        rel[:entity_attributes]["0"]['id'] = rel[:entity_attributes]["0"]['identifier']
      else
        rel[:entity_attributes]["0"]['id'] = "info:fedora/#{model.id}#externalRelation#{rel_index.to_s}"
      end
      influences.push(rel[:entity_attributes]["0"]['id'])
      rel['id'] = "info:fedora/%s#qualifiedRelation%d" % [model.id, rel_index]
      model.qualifiedRelation.build(rel)
      model.qualifiedRelation[rel_index].entity = nil
      rel[:entity_attributes]["0"][:type] = RDF::PROV.Entity
      model.qualifiedRelation[rel_index].entity.build(rel[:entity_attributes]["0"])
    end
    model.influence = influences
  end

  def buildFundingActivity(params)
    model.funding = nil
    id0 = "info:fedora/%s#fundingActivity" % model.id
    vals = {'id' => id0, :wasAssociatedWith => [], :hasFundingAward => nil}
    awardCount = 0
    # Funder has to have name of funder and whom the funder funds
    funders = []
    params[:funder_attributes].values.each do |funder|
      if !funder.nil? && !funder.empty? & funder.has_key?(:agent_attributes) && !funder[:agent_attributes]["0"][:name].empty? && !funder[:funds].empty?
        funders << funder
      end
    end
    # Funding award has to be either yes or no
    if params.has_key?(:hasFundingAward) && (params[:hasFundingAward] == "yes" || params[:hasFundingAward] == "no")
      vals[:hasFundingAward] = params[:hasFundingAward]
    end
    # Build funding activity
    if !vals[:hasFundingAward].nil? && vals[:hasFundingAward] == "no"
      vals[:wasAssociatedWith] = nil
      vals[:funder] = nil
      model.funding.build(vals)
    elsif funders.length > 0
      funders.each_with_index do |funder, n|
        b1 = "info:fedora/%s#funder%d" % [model.id, n]
        vals[:wasAssociatedWith].push(b1)
      end
      vals[:hasFundingAward] = "yes"
      model.funding.build(vals)
      model.funding[0].funder = nil
      #(0..params[:funder_attributes].length-1).each do |n|
      funders.each_with_index do |funder, n|
        # Clean the funder attributes
        funder["id"] = "info:fedora/%s#fundingAssociation%d" % [model.id, n]
        funder["role"] = RDF::FRAPO.FundingAgency
        #TODO: Need to be smart about Ids for funder[:funds]. 
        #  Should point to existing author or project in metadata.
        #  Add check here for funder[:funds]
        if funder[:annotation].nil? || funder[:annotation].empty?
          funder[:annotation] = nil
        end
        # Clean the agent attributes for the funder
        funder[:agent_attributes]["0"]["id"] = "info:fedora/%s#funder%d" % [model.id, n]
        funder[:agent_attributes]["0"]["type"] = RDF::FRAPO.FundingAgency
        if !funder[:agent_attributes]["0"].nil? && funder[:agent_attributes]["0"].has_key?("sameAs") && funder[:agent_attributes]["0"][:sameAs].empty?
          funder[:agent_attributes]["0"][:sameAs] = nil
        end
        # Clean the awards attributes for the funder
        awards = []
        funder[:awards_attributes].values.each do |award|
          if !award["grantNumber"].empty?
            award["id"] = "info:fedora/%s#fundingAward%d" % [model.id, awardCount]
            awardCount += 1
            awards << award
          end
        end
        funder[:awards_attributes] = awards
        # Build the funder
        # Important - Do not build before setting the correct Ids for agent and award. 
        #             It may overwrite previous funders if ids are not incremented in form repeater
        model.funding[0].funder.build(funder)
        model.funding[0].funder[n].agent = nil
        model.funding[0].funder[n].awards = nil
        model.funding[0].funder[n].agent.build(funder[:agent_attributes]["0"])
        awards.each_with_index do |award, n2|
          model.funding[0].funder[n].awards.build(award)
        end
      end
    elsif !vals[:hasFundingAward].nil?
      vals[:wasAssociatedWith] = nil
      vals[:funder] = nil
      model.funding.build(vals)
    end
  end

  def buildCreationActivity(params)
    model.creation = nil
    creators = []
    # has to have name of creator
    normalizeParams(params[:creator_attributes]).each do |c|
      if !c.nil? && c.has_key?("name") && !c[:name].empty?
        c.each do |k, v|
          c[k] = nil if v.empty?
        end
        creators << c
      end
    end
    if !creators.empty?
      id0 = "info:fedora/%s#creationActivity" % model.id
      vals = {'id' => id0, :wasAssociatedWith=> [], :type => RDF::PROV.Activity}
      (0..creators.length-1).each do |n|
        b1 = "info:fedora/%s#creator%d" % [model.id, n]
        vals[:wasAssociatedWith].push(b1)
      end
      model.creation.build(vals)
      affiliationCount = 0
      model.creation[0].creator = nil
      creators.each_with_index do |c1, c1_index|
        b1 = "info:fedora/%s#creator%d" % [model.id, c1_index]
        agent = { 'id'=> b1, :name => c1[:name], :email => c1[:email], :type => RDF::VCARD.Individual, :sameAs => c1[:sameAs] }
        b2 = "info:fedora/%s#creationAssociation%d" % [model.id, c1_index]
        c1['id'] = b2
        #c1[:agent] = b1
        c1[:type] = RDF::PROV.Association
        if c1.has_key?(:role) && c1[:role].is_a?(Array) && c1[:role].any?
          c1[:role].reject{|v| v.nil? || v.empty?}
        end
        model.creation[0].creator.build(c1)
        model.creation[0].creator[c1_index].agent = nil
        model.creation[0].creator[c1_index].agent.build(agent)
        model.creation[0].creator[c1_index].agent[0].affiliation = nil
        if c1[:affiliation] && c1[:affiliation].has_key?(:name) and !c1[:affiliation][:name].empty?
          c1[:affiliation]['id'] = "info:fedora/%s#affiliation%d" % [model.id, affiliationCount]
          model.creation[0].creator[c1_index].agent[0].affiliation.build(c1[:affiliation])
          affiliationCount += 1
        end # if affiliation
      end #for each creator
    end #if creator attributes
  end

  def buildTitularActivity(params)
    model.titularActivity = nil
    creators = []
    normalizeParams(params[:titular_attributes]).each do |c|
      # has to have name of titular
      if !c.nil? && c.has_key?("name") && !c[:name].empty?
        c.each do |k, v|
          c[k] = nil if v.empty?
        end
        creators << c
      end
    end
    if !creators.empty?
      id0 = "info:fedora/%s#titularActivity" % model.id
      vals = {'id' => id0, :wasAssociatedWith=> [], :type => RDF::PROV.Activity}
      (0..creators.length-1).each do |n|
        b1 = "info:fedora/%s#titular%d" % [model.id, n]
        vals[:wasAssociatedWith].push(b1)
      end
      model.titularActivity.build(vals)
      affiliationCount = 0
      model.titularActivity[0].titular = nil
      creators.each_with_index do |c1, c1_index|
        b1 = "info:fedora/%s#titular%d" % [model.id, c1_index]
        agent = { 'id'=> b1, :name => c1[:name], :roleHeldBy => c1[:roleHeldBy] }
        b2 = "info:fedora/%s#titularAssociation%d" % [model.id, c1_index]
        c1['id'] = b2
        #c1[:agent] = b1
        c1[:type] = RDF::PROV.Association
        if c1.has_key?(:role) && c1[:role].is_a?(Array) && c1[:role].any?
          c1[:role].reject{|v| v.nil? || v.empty?}
        end
        model.titularActivity[0].titular.build(c1)
        model.titularActivity[0].titular[c1_index].agent = nil
        model.titularActivity[0].titular[c1_index].agent.build(agent)
        model.titularActivity[0].titular[c1_index].agent[0].affiliation = nil
        if c1[:affiliation] && c1[:affiliation].has_key?(:name) and !c1[:affiliation][:name].empty?
          c1[:affiliation]['id'] = "info:fedora/%s#titularAffiliation%d" % [model.id, affiliationCount]
          model.titularActivity[0].titular[c1_index].agent[0].affiliation.build(c1[:affiliation])
          affiliationCount += 1
        end # if affiliation
      end #for each titular
    end #if titular attributes
  end

  def buildPublicationActivity(params)
    model.publication = nil
    params.each do |k, v|
      params[k] = nil if v.empty?
    end
    id0 = "info:fedora/%s#publicationActivity" % model.id
    params['id'] = id0
    params[:type] = RDF::PROV.Activity
    params[:wasAssociatedWith] = []
    if !params["publisher_attributes"].nil? && !params[:publisher_attributes].empty?
      if params[:publisher_attributes]["0"].has_key?(:agent_attributes) && !params[:publisher_attributes]["0"][:agent_attributes].nil? && !params[:publisher_attributes]["0"][:agent_attributes].empty?
        p1 = params[:publisher_attributes]["0"][:agent_attributes]["0"]
        if p1.has_key?(:name) and not p1[:name].empty?
          params[:wasAssociatedWith].push("info:fedora/%s#publisher" % model.id)
        end
      end
    end
    model.publication.build(params)
    model.publication[0].hasDocument = nil
    if !params[:hasDocument_attributes].nil? && !params[:hasDocument_attributes].empty?
      if (params[:hasDocument_attributes]["0"].except(:journal_attributes, :series_attributes).any? {|k,v| !v.nil? && !v.empty?}) or \
        (params[:hasDocument_attributes]["0"].has_key?(:journal_attributes) && \
          params[:hasDocument_attributes]["0"][:journal_attributes]["0"].any? {|k,v| !v.nil? && !v.empty?}) or \
        (params[:hasDocument_attributes]["0"].has_key?(:series_attributes) && \
          params[:hasDocument_attributes]["0"][:series_attributes]["0"].any? {|k,v| !v.nil? && !v.empty?})
        params[:hasDocument_attributes]["0"]['id'] = "info:fedora/%s#publicationDocument" % model.id
        model.publication[0].hasDocument.build(params[:hasDocument_attributes]["0"])
        model.publication[0].hasDocument[0].journal = nil
        model.publication[0].hasDocument[0].series = nil
        if (params[:hasDocument_attributes]["0"].has_key?(:journal_attributes) && \
          params[:hasDocument_attributes]["0"][:journal_attributes]["0"].any? {|k,v| !v.nil? && !v.empty?})
          params[:hasDocument_attributes]["0"][:journal_attributes]["0"]['id'] = "info:fedora/%s#publicationJournal" % model.id
          model.publication[0].hasDocument[0].journal.build(params[:hasDocument_attributes]["0"][:journal_attributes]["0"])
        end
        if (params[:hasDocument_attributes]["0"].has_key?(:series_attributes) && \
          params[:hasDocument_attributes]["0"][:series_attributes]["0"].any? {|k,v| !v.nil? && !v.empty?})
          params[:hasDocument_attributes]["0"][:series_attributes]["0"]['id'] = "info:fedora/%s#publicationSeries" % model.id
          model.publication[0].hasDocument[0].series.build(params[:hasDocument_attributes]["0"][:series_attributes]["0"])
        end
      end
    end
    model.publication[0].publisher = nil
    if !params["publisher_attributes"].nil? && !params[:publisher_attributes].empty?
      if params[:publisher_attributes]["0"].has_key?(:agent_attributes) && !params[:publisher_attributes]["0"][:agent_attributes].nil? && !params[:publisher_attributes]["0"][:agent_attributes].empty?
        params[:publisher_attributes]["0"][:agent_attributes]["0"].each do |k, v|
          params[:publisher_attributes]["0"][:agent_attributes]["0"][k] = nil if v.empty?
        end
        if params[:publisher_attributes]["0"][:agent_attributes]["0"].has_key?(:name) && !params[:publisher_attributes]["0"][:agent_attributes]["0"][:name].nil?
          p = {'id'=>"info:fedora/%s#publicationAssociation" % model.id, :type => RDF::PROV.Association, :role => RDF::DC.publisher}
          model.publication[0].publisher.build(p)
          model.publication[0].publisher[0].agent = nil
          params[:publisher_attributes]["0"][:agent_attributes]["0"]["id"] = "info:fedora/%s#publisher" % model.id
          params[:publisher_attributes]["0"][:agent_attributes]["0"][:type] = RDF::VCARD.Organization
          model.publication[0].publisher[0].agent.build(params[:publisher_attributes]["0"][:agent_attributes]["0"])
        end
      end
    end
  end

  def buildTemporalData(params)
    model.temporal = nil
    if !params[:start].empty? || !params[:end].empty?
      params.each do |k, v|
        params[k] = nil if v.empty?
      end
      params['id'] = "info:fedora/#{model.id}#temporal"
      #TODO: On adding this the data is not retreived after create (because embargoDate is also of the same type?)
      #params['type'] = RDF::TIME.TemporalEntity
      model.temporal.build(params)
    end
  end

  def buildDateCollected(params)
    model.dateCollected = nil
    if !params[:start].empty? || !params[:end].empty?
      params.each do |k, v|
        params[k] = nil if v.empty?
      end
      params['id'] = "info:fedora/#{model.id}#dateCollected"
      #TODO: On adding this the data is not retreived after create (because embargoDate is also of the same type?)
      #params['type'] = RDF::TIME.TemporalEntity
      model.dateCollected.build(params)
    end
  end

  def buildSpatialData(params)
    model.spatial = nil
    if !params[:value].empty?
      params['id'] = "info:fedora/#{model.id}#spatial"
      model.spatial.build(params)
    end
  end

  def buildStorageAgreementData(params)
    model.storageAgreement = nil
    if !params[:title].empty? || !params[:identifier].empty?
      params['id'] = "info:fedora/#{model.id}#storageAgreement"
      model.storageAgreement.build(params)
    end
  end

  def buildValidityDate(params)
    model.valid = nil
    if !params[:start].empty? || !params[:end].empty?
      params.each do |k, v|
        params[k] = nil if v.empty?
      end
      params['id'] = "info:fedora/#{model.id}#valid"
      #TODO: On adding this the data is not retreived after create (because embargoDate is also of the same type?)
      #params['type'] = RDF::TIME.TemporalEntity
      model.valid.build(params)
    end
  end

  def buildInvoiceData(params)
    model.invoice = nil
    if ((params.has_key?('description') && !params[:description].empty?) || \
       (params.has_key?('identifier') && !params[:identifier].empty?) || \
       (params.has_key?('source') && !params[:source].empty?))
      params.each do |k, v|
        params[k] = nil if v.empty?
      end
      params['id'] = "info:fedora/#{model.id}#invoice"
      model.invoice.build(params)
    end
  end


  def validateEmbargoDates(params, id, datePublished)
    # If endDate is given
    # 	endDateType = Stated
    #   endDate = date
    # If duration is given and startDate is today
    #   startDateType = Date
    #   endDateType = Defined
    #	endDate = today's date + duration
    # If duration is given and startDate is particular date
    #   startDateType = Date
    #   endDateType = Defined
    #	endDate = date + duration
    # If duration is given and startDate is publication date
    #   startDateType = Publication date
    #   If publication date is known
    #     endDateType = Defined
    #	  endDate = publication date + duration
    #   If publication date is not known
    #     endDateType = Approximate
    #	  endDate = today + duration
    vals = {
        'id' => "%s#accessRights"% id,
        :embargoStatus => nil,
        :embargoDate => [{
                             'id' => nil,
                             :start => [{:date => nil, :label => nil, 'id' => nil}],
                             :duration => [{:years => nil, :months => nil, 'id' => nil}],
                             :end => [{:date => nil, :label => nil, 'id' => nil}]
                         }],
        :embargoReason =>  nil,
        :embargoRelease => nil
    }

    # embargoStatus = open
    if params[:embargoStatus] == "Open access"
      vals[:embargoStatus] = params[:embargoStatus]
    elsif params[:embargoStatus] == "Closed access"
      vals[:embargoStatus] = params[:embargoStatus]
      if !params[:embargoReason].nil? && !params[:embargoReason].empty?
        vals[:embargoReason] = params[:embargoReason]
      end
      if !params[:embargoRelease].nil? && !params[:embargoRelease].empty? && Sufia.config.embargo_release_methods.include?(params[:embargoRelease])
        vals[:embargoRelease] = params[:embargoRelease]
      end
    elsif params[:embargoStatus] == "Embargoed"
      vals[:embargoStatus] = params[:embargoStatus]
      vals[:embargoDate][0]['id'] = "%s#embargoDate"% id
      if !params[:embargoReason].nil? && !params[:embargoReason].empty?
        vals[:embargoReason] = params[:embargoReason]
      end
      if !params[:embargoRelease].nil? && !params[:embargoRelease].empty? && Sufia.config.embargo_release_methods.include?(params[:embargoRelease])
        vals[:embargoRelease] = params[:embargoRelease]
      end
      startDate = nil
      startDateType = nil
      endDate = nil
      endDateType = nil
      numberOfYears = nil
      numberOfMonths = nil
      if !params[:embargoDate].nil?
        if !params[:embargoDate][:end].nil?
          if !params[:embargoDate][:end][:date].nil? && !params[:embargoDate][:end][:label].nil? && params[:embargoDate][:end][:label] == "Stated"
            begin
              endDate = Time.parse(params[:embargoDate][:end][:date])
            rescue
              endDate = nil
            end
          end
        end
        if !endDate.nil?
          vals[:embargoDate][0][:end][0]['id'] = "%s#embargoEnd"% id
          vals[:embargoDate][0][:end][0][:date] = endDate.strftime("%d %b %Y")
          vals[:embargoDate][0][:end][0][:label] = "Stated"
        else
          # get the start date
          if !params[:embargoDate][:start].nil?
            if params[:embargoDate][:start][:label] == "Today"
              startDateType = "Date"
              startDate = Time.now
            elsif params[:embargoDate][:start][:label] == "Publication date"
              startDateType = "Publication date"
              begin
                startDate = Time.parse(datePublished)
              rescue
                startDate = nil
              end
            elsif !params[:embargoDate][:start][:date].nil?
              startDateType = "Date"
              begin
                startDate = Time.parse(params[:embargoDate][:start][:date])
              rescue
                startDate = nil
              end
            end
          end
          # Get the duration
          if !params[:embargoDate][:duration].nil?
            if params[:embargoDate][:duration][:years]
              numberOfYears = params[:embargoDate][:duration][:years].to_i
            end
            if params[:embargoDate][:duration][:months]
              numberOfMonths = params[:embargoDate][:duration][:months].to_i
            end
          end
          if (!numberOfYears.nil? || !numberOfMonths.nil?) && (numberOfYears > 0 || numberOfMonths > 0)
            if startDate.nil?
              endDateType = "Approximate"
              startDate = Time.now
            else
              endDateType = "Defined"
            end
            endDate = startDate + numberOfYears.years + numberOfMonths.months
            vals[:embargoDate][0][:start][0]['id'] = "%s#embargoStart"% id
            vals[:embargoDate][0][:start][0][:date] = startDate.strftime("%d %b %Y")
            vals[:embargoDate][0][:start][0][:label] = startDateType
            vals[:embargoDate][0][:duration][0]['id'] = "%s#embargoDuration"% id
            vals[:embargoDate][0][:duration][0][:years] = numberOfYears.to_s
            vals[:embargoDate][0][:duration][0][:months] = numberOfMonths.to_s
            vals[:embargoDate][0][:end][0]['id'] = "%s#embargoEnd"% id
            vals[:embargoDate][0][:end][0][:date] = endDate.strftime("%d %b %Y")
            vals[:embargoDate][0][:end][0][:label] = endDateType
          end #if duration
        end #if end date
      end #if embargoDate
    end # if embargoed
    vals
  end #validateEmbargoDates
end
