require 'ora/embargo_date'
require "vocabulary/frapo"
#require "vocabulary/time"

module Ora

  module_function

  def validatePermissions(params)
    if params.is_a?(Hash)
      params = params.values()
    end
    params.each do |p|
      if p.has_key? 'name' and !p["name"].empty? and p.has_key? 'access' and !p["access"].empty?
        p["type"] = "user"
      else
        params.delete(p)
      end #check name and access exists
    end
    params
  end

  def validatePermissionsToRevoke(params, depositor)
    params['permissions_attributes'].each do |p|
      if p["type"].downcase != "group" && p["name"] != depositor
        if p.has_key? 'name' and !p["name"].empty? and p.has_key? 'access' and !p["access"].empty?
          p["type"] = "user"
          p["_destroy"] = true
        else
          params['permissions_attributes'].delete(p)
        end #check name and access exists
      else
        params['permissions_attributes'].delete(p)
      end # check not type = group and not depositor
    end # loop each permission
    params
  end

  def validateWorkflow(params)
    params[:workflows_attributes] = [params[:workflows_attributes]]
    if params[:workflows_attributes][0].has_key?(:entries_attributes)
      params[:workflows_attributes][0][:entries_attributes] = [params[:workflows_attributes][0][:entries_attributes]]
    end
    if params[:workflows_attributes][0].has_key?(:comments_attributes)
      params[:workflows_attributes][0][:comments_attributes] = [params[:workflows_attributes][0][:comments_attributes]]
    end
    params
  end

  def buildLanguage(params, article)
    #remove_blank_assertions for language and build
    article.language = nil
    if !params[:languageLabel].empty?
      params.each do |k, v|
        params[k] = nil if v.empty?
      end
      params['id'] = "info:fedora/#{article.id}#language"
      article.language.build(params)
    end
    article
  end

  def buildSubject(params, article)
    article.subject = nil
    if params.is_a?(Hash)
      params = params.values()
    end
    params.each do |s|
      if s[:subjectLabel].empty?
         params.delete(s)
      end
    end
    params.each_with_index do |s, s_index|
      s.each do |k, v|
        s[k] = nil if v.empty?
      end
      s['id'] = "info:fedora/#{article.id}#subject#{s_index.to_s}"
      article.subject.build(s)
    end
    article
  end

  def buildWorktype(params, article)
    params = params.except(:typeAuthority)
    article.worktype = nil
    if !params[:typeLabel].empty?
      model = article.class.to_s.downcase
      if Sufia.config.type_authorities[model].include?(params[:typeLabel])
        params[:typeAuthority] = Sufia.config.type_authorities[model][params[:typeLabel]]
      end
      params['id'] = "info:fedora/#{article.id}#type"
      article.worktype.build(params)
    else
      params[:typeLabel] = model.capitalize
      params[:typeAuthority] = Sufia.config.type_authorities[model][model.capitalize]
      params['id'] = "info:fedora/#{article.id}#type"
      article.worktype.build(params)
    end
    article
  end

  def buildRightsActivity(params, article)
    ag = []
    article.rightsActivity = nil
    if params.has_key?(:license)
      lsp = params[:license].except(:licenseURI)
      article.license = nil
      if !lsp[:licenseLabel].empty? or !lsp[:licenseStatement].empty?
        if Sufia.config.license_urls.include?(lsp[:licenseLabel])
          lsp[:licenseURI] = Sufia.config.license_urls[lsp[:licenseLabel]]
        elsif isURI(lsp[:licenseStatement])
          lsp[:licenseURI] = lsp[:licenseStatement]
          lsp[:licenseStatement] = nil
        end
        lsp['id'] = "info:fedora/#{article.id}#license"
        lsp.each do |k, v|
          lsp[k] = nil if v.empty?
        end
        article.license.build(lsp)
        ag.push("info:fedora/#{article.id}#license")
      end
    end
    if params.has_key?(:rights)
      rp = params[:rights].except(:rightsType)
      article.rights = nil
      if !rp[:rightsStatement].empty?
        rp.each do |k, v|
          rp[k] = nil if v.empty?
        end
      end
      rp[:rightsType] = RDF::DC.RightsStatement
      rp['id'] = "info:fedora/#{article.id}#rights"
      article.rights.build(rp)
      ag.push("info:fedora/#{article.id}#rights")
    end
    if !ag.empty?
      rap = {activityUsed: "info:fedora/#{article.id}", "id" => "info:fedora/#{article.id}#rightsActivity", activityType: RDF::PROV.Activity, activityGenerated: ag}
      article.rightsActivity.build(rap)
    end
    article
  end

  def buildAccessRights(params, article, datePublished)
    params = Ora.validateEmbargoDates(params, "info:fedora/#{article.id}", datePublished)
    article.accessRights = nil
    article.accessRights.build(params)
    article.accessRights[0].embargoDate = nil
    if params[:embargoStatus] == "Embargoed"
      article.accessRights[0].embargoDate.build(params[:embargoDate][0])
      article.accessRights[0].embargoDate[0].start = nil
      article.accessRights[0].embargoDate[0].duration = nil
      article.accessRights[0].embargoDate[0].end = nil
      if !params[:embargoDate][0][:start].nil? && (!params[:embargoDate][0][:start][0][:label].nil? || !params[:embargoDate][0][:start][0][:date].nil?)
        article.accessRights[0].embargoDate[0].start.build(params[:embargoDate][0][:start][0])
      end
      if !params[:embargoDate][0][:duration].nil? && (!params[:embargoDate][0][:duration][0][:years].nil? || !params[:embargoDate][0][:duration][0][:months].nil?)
        article.accessRights[0].embargoDate[0].duration.build(params[:embargoDate][0][:duration][0])
      end
      if !params[:embargoDate][0][:end].nil? && (!params[:embargoDate][0][:end][0][:label].nil? || !params[:embargoDate][0][:end][0][:date].nil?)
        article.accessRights[0].embargoDate[0].end.build(params[:embargoDate][0][:end][0])
      end
    end
    article
  end

  def buildInternalRelations(params, article, datePublished, contents)
    article.hasPart = nil
    select = {}
    count = 0
    for ds in contents
      dsid = ds['url'].split("/")[-1]
      params.each do |k, h|
        if h[:identifier] == dsid
          select = h
          select['id'] = "info:fedora/#{article.id}/datastreams/#{dsid}"
        end
      end
      select.each do |k, v|
        select[k] = nil if v.empty?
      end
      article.hasPart.build(select)
      article.hasPart[count].accessRights = nil
      endDate = nil
      if select.has_key?(:accessRights)
        ar = Ora.validateEmbargoDates(select[:accessRights], "info:fedora/#{article.id}/datastreams/#{dsid}", datePublished)
        article.hasPart[count].accessRights.build(ar)
        article.hasPart[count].accessRights[0].embargoDate = nil
        if ar[:embargoStatus] == "Embargoed"
          article.hasPart[count].accessRights[0].embargoDate.build(ar[:embargoDate][0])
          article.hasPart[count].accessRights[0].embargoDate[0].start = nil
          article.hasPart[count].accessRights[0].embargoDate[0].duration = nil
          article.hasPart[count].accessRights[0].embargoDate[0].end = nil
          if !ar[:embargoDate][0][:start].nil? && (!ar[:embargoDate][0][:start][0][:label].nil? || !ar[:embargoDate][0][:start][0][:date].nil?)
            article.hasPart[count].accessRights[0].embargoDate[0].start.build(ar[:embargoDate][0][:start][0])
          end
          if !ar[:embargoDate][0][:duration].nil? && (!ar[:embargoDate][0][:duration][0][:years].nil? || !ar[:embargoDate][0][:duration][0][:months].nil?)
            article.hasPart[count].accessRights[0].embargoDate[0].duration.build(ar[:embargoDate][0][:duration][0])
          end
          if !ar[:embargoDate][0][:end].nil? && (!ar[:embargoDate][0][:end][0][:label].nil? || !ar[:embargoDate][0][:end][0][:date].nil?)
            article.hasPart[count].accessRights[0].embargoDate[0].end.build(ar[:embargoDate][0][:end][0])
          end
        end
      end
      count += 1
    end
    article
  end

  def buildExternalRelations(params, article)
    params = params.values()
    params.each_with_index do |rel, rel_index|
      hasInfo = false
      rel[:entity_attributes]["0"].each do |k, v|
        if v.empty?
          params[rel_index][:entity_attributes]["0"][k] = nil
        else
          hasInfo = true
        end
      end
      if !hasInfo || rel[:relation].empty?
        params.delete(params[rel_index])
      end
    end
    article.qualifiedRelation = nil
    article.influence = nil
    influences = []
    params.each_with_index do |rel, rel_index|
      influences.push(rel[:entity_attributes]["0"]['id'])
      rel['id'] = "info:fedora/%s#qualifiedRelation%d" % [article.id, rel_index]
      article.qualifiedRelation.build(rel)
      article.qualifiedRelation[rel_index].entity = nil
      rel[:entity_attributes]["0"][:type] = RDF::PROV.Entity
      article.qualifiedRelation[rel_index].entity.build(rel[:entity_attributes]["0"])
    end
    article.influence = influences
    article
  end

  def buildFundingActivity(params, article)
    article.funding = nil
    # has to have name of funder and whom the funder funds
    funders = params[:funder_attributes].values()
    funders.each do |funder|
      #funder = params[:funder_attributes]["#{n}"]
      if funder.nil? || funder.empty? || !funder.has_key?(:agent_attributes)
        #params[:funder_attributes].delete(funder)
        funders.delete(funder)
      elsif funder[:agent_attributes]["0"][:name].empty? and funder[:funds].empty?
        #params[:funder_attributes].delete(funder)
        funders.delete(funder)
      end
    end
    id0 = "info:fedora/%s#fundingActivity" % article.id
    vals = {'id' => id0, :wasAssociatedWith=> []}
    awardCount = 0
    if funders.length > 0
      funders.each_with_index do |funder, n|
        b1 = "info:fedora/%s#funder%d" % [article.id, n]
        vals[:wasAssociatedWith].push(b1)
      end
      article.funding.build(vals)
      article.funding[0].funder = nil
      #(0..params[:funder_attributes].length-1).each do |n|
      funders.each_with_index do |funder, n|
        # Clean the funder attributes and build
        funder["id"] = "info:fedora/%s#fundingAssociation%d" % [article.id, n]
        funder["role"] = RDF::FRAPO.FundingAgency
        #TODO: Need to be more smart about these Ids. These assumptions are wrong
        if funder[:funds] == "Author"
          funder[:funds] = "info:fedora/#{params[:pid]}#creator1"
        elsif funder[:funds] == "Publication"
          funder[:funds] = "info:fedora/#{params[:pid]}"
        elsif funder[:funds] == "Project"
          funder[:funds] = "info:fedora/#{params[:pid]}#project1"
        end
        if funder[:annotation].empty?
          funder[:annotation] = nil
        end
        article.funding[0].funder.build(funder)
        article.funding[0].funder[n].agent = nil
        article.funding[0].funder[n].awards = nil
        # Clean the agent attributes for the funder and build
        funder[:agent_attributes]["0"]["id"] = "info:fedora/%s#funder%d" % [article.id, n]
        funder[:agent_attributes]["0"]["type"] = RDF::FRAPO.FundingAgency
        if funder[:agent_attributes]["0"][:sameAs].empty?
          funder[:agent_attributes]["0"][:sameAs] = nil
        end
        article.funding[0].funder[n].agent.build(funder[:agent_attributes]["0"])
        # Clean the awards attributes for the funder and build
        awards = funder[:awards_attributes].values()
        awards.each do |award|
          if award["grantNumber"].empty?
            awards.delete(award)
          end
        end
        awards.each_with_index do |award, n2|
          award["id"] = "info:fedora/%s#fundingAward%d" % [article.id, awardCount]
          article.funding[0].funder[n].awards.build(award)
          awardCount += 1
        end
      end
    end
    article
  end

  def buildCreationActivity(params, article)
    article.creation = nil
    if params[:creator_attributes].is_a?(Hash)
      params[:creator_attributes] = params[:creator_attributes].values()
    end
    # has to have name of creator
    params[:creator_attributes].each do |c|
      if c.nil? || c.empty? || !c.has_key?("name")
        params[:creator_attributes].delete(c)
      elsif c[:name].empty?
        params[:creator_attributes].delete(c)
      else
        c.each do |k, v|
          c[k] = nil if v.empty?
        end
      end
    end 
    if !params[:creator_attributes].empty?
      id0 = "info:fedora/%s#creationActivity" % article.id
      vals = {'id' => id0, :wasAssociatedWith=> [], :type => RDF::PROV.Activity}
      (0..params[:creator_attributes].length-1).each do |n|
        b1 = "info:fedora/%s#creator%d" % [article.id, n]
        vals[:wasAssociatedWith].push(b1)
      end 
      article.creation.build(vals)
      affiliationCount = 0
      article.creation[0].creator = nil
      params[:creator_attributes].each_with_index do |c1, c1_index|
        b1 = "info:fedora/%s#creator%d" % [article.id, c1_index]
        agent = { 'id'=> b1, :name => c1[:name], :email => c1[:email], :type => RDF::VCARD.Individual, :sameAs => c1[:sameAs] }
        b2 = "info:fedora/%s#creationAssociation%d" % [article.id, c1_index]
        c1['id'] = b2
        #c1[:agent] = b1
        c1[:type] = RDF::PROV.Association
        article.creation[0].creator.build(c1)
        article.creation[0].creator[c1_index].agent = nil
        article.creation[0].creator[c1_index].agent.build(agent)
        article.creation[0].creator[c1_index].agent[0].affiliation = nil
        if c1[:affiliation] && c1[:affiliation].has_key?(:name) and !c1[:affiliation][:name].empty?
          c1[:affiliation]['id'] = "info:fedora/%s#affiliation%d" % [article.id, affiliationCount]
          article.creation[0].creator[c1_index].agent[0].affiliation.build(c1[:affiliation])
          affiliationCount += 1
        end # if affiliation
      end #for each creator
    end #if creator attributes
    article
  end

  def buildPublicationActivity(params, article)
    article.publication = nil
    params.each do |k, v|
      params[k] = nil if v.empty?
    end
    id0 = "info:fedora/%s#publicationActivity" % article.id
    params['id'] = id0
    params[:type] = RDF::PROV.Activity
    if !params[:publisher_attributes]["0"][:name].empty?
      params[:wasAssociatedWith] = ["info:fedora/%s#publisher" % article.id]
    end
    article.publication.build(params)
    article.publication[0].hasDocument = nil
    if !params[:hasDocument_attributes].empty?
      if (params[:hasDocument_attributes]["0"].except(:journal_attributes, :series_attributes).any? {|k,v| !v.nil? && !v.empty?}) or \
        (params[:hasDocument_attributes]["0"].has_key?(:journal_attributes) && \
          params[:hasDocument_attributes]["0"][:journal_attributes]["0"].any? {|k,v| !v.nil? && !v.empty?}) or \
        (params[:hasDocument_attributes]["0"].has_key?(:series_attributes) && \
          params[:hasDocument_attributes]["0"][:series_attributes]["0"].any? {|k,v| !v.nil? && !v.empty?})
        params[:hasDocument_attributes]["0"]['id'] = "info:fedora/%s#publicationDocument" % article.id
        article.publication[0].hasDocument.build(params[:hasDocument_attributes]["0"])
        article.publication[0].hasDocument[0].journal = nil
        article.publication[0].hasDocument[0].series = nil
        if (params[:hasDocument_attributes]["0"].has_key?(:journal_attributes) && \
          params[:hasDocument_attributes]["0"][:journal_attributes]["0"].any? {|k,v| !v.nil? && !v.empty?})
          params[:hasDocument_attributes]["0"][:journal_attributes]["0"]['id'] = "info:fedora/%s#publicationJournal" % article.id
          article.publication[0].hasDocument[0].journal.build(params[:hasDocument_attributes]["0"][:journal_attributes]["0"])
        end
        if (params[:hasDocument_attributes]["0"].has_key?(:series_attributes) && \
          params[:hasDocument_attributes]["0"][:series_attributes]["0"].any? {|k,v| !v.nil? && !v.empty?})
          params[:hasDocument_attributes]["0"][:series_attributes]["0"]['id'] = "info:fedora/%s#publicationSeries" % article.id
          article.publication[0].hasDocument[0].series.build(params[:hasDocument_attributes]["0"][:series_attributes]["0"])
        end
      end
    end
    article.publication[0].publisher = nil
    if !params[:publisher_attributes].empty?
      params[:publisher_attributes]["0"].each do |k, v|
        params[:publisher_attributes]["0"][k] = nil if v.empty?
      end
      if !params[:publisher_attributes]["0"][:name].nil?
        params[:publisher_attributes]["0"]['id'] = "info:fedora/%s#publicationAssociation" % article.id
        params[:publisher_attributes]["0"][:type] = RDF::PROV.Association
        params[:publisher_attributes]["0"][:agent] = "info:fedora/%s#publisher" % article.id
        params[:publisher_attributes]["0"][:role] = RDF::DC.publisher
        article.publication[0].publisher.build(params[:publisher_attributes]["0"])
      end
    end
    article
  end

  def buildTemporalData(params, article)
    article.temporal = nil
    if !params[:start].empty? || !params[:end].empty?
      params.each do |k, v|
        params[k] = nil if v.empty?
      end
      params['id'] = "info:fedora/#{article.id}#temporal"
      #TODO: On adding this the data is not retreived after create (because embargoDate is also of the same type?)
      #params['type'] = RDF::TIME.TemporalEntity
      article.temporal.build(params)
    end
    article
  end

  def buildDateCollected(params, article)
    article.dateCollected = nil
    if !params[:start].empty? || !params[:end].empty?
      params.each do |k, v|
        params[k] = nil if v.empty?
      end
      params['id'] = "info:fedora/#{article.id}#dateCollected"
      #TODO: On adding this the data is not retreived after create (because embargoDate is also of the same type?)
      #params['type'] = RDF::TIME.TemporalEntity
      article.dateCollected.build(params)
    end
    article
  end

  def buildSpatialData(params, article)
    article.spatial = nil
    if !params[:value].empty?
      params['id'] = "info:fedora/#{article.id}#spatial"
      article.spatial.build(params)
    end
    article
  end

  def buildStorageAgreementData(params, article)
    article.storageAgreement = nil
    if !params[:title].empty? || !params[:identifier].empty?
      params['id'] = "info:fedora/#{article.id}#storageAgreement"
      article.storageAgreement.build(params)
    end
    article
  end

  def buildValidityDate(params, article)
    article.valid = nil
    if !params[:start].empty? || !params[:end].empty?
      params.each do |k, v|
        params[k] = nil if v.empty?
      end
      params['id'] = "info:fedora/#{article.id}#valid"
      #TODO: On adding this the data is not retreived after create (because embargoDate is also of the same type?)
      #params['type'] = RDF::TIME.TemporalEntity
      article.valid.build(params)
    end
    article
  end

  def buildInvoiceData(params, article)
    article.invoice = nil
    if !params[:identifier].empty? || !params[:source].empty?
      params.each do |k, v|
        params[k] = nil if v.empty?
      end
      params['id'] = "info:fedora/#{article.id}#invoice"
      article.invoice.build(params)
    end
    article
  end

  def buildMetadata(params, article, contents)
    # Validate permissions
    if params.has_key?(:permissions_attributes)
      params[:permissions_attributes] = Ora.validatePermissions(params[:permissions_attributes])
    end
    article.attributes = params

    #remove_blank_assertions for language and build
    if params.has_key?(:language)
      article = Ora.buildLanguage(params[:language], article)
    end

    #remove_blank_assertions for subject and build
    if params.has_key?(:subject)
      article = Ora.buildSubject(params[:subject], article)
    end

    # Remove blank assertions for worktype and build
    if params.has_key?(:worktype)
      article = Ora.buildWorktype(params[:worktype], article)
    end

    #Remove blank assertions for temporal coverage and build
    if params.has_key?(:temporal)
      article = Ora.buildTemporalData(params[:temporal], article)
    end

    #Remove blank assertions for date collected and build
    if params.has_key?(:dateCollected)
      article = Ora.buildDateCollected(params[:dateCollected], article)
    end

    #Remove blank assertions for spatial coverage and build
    if params.has_key?(:spatial)
      article = Ora.buildSpatialData(params[:spatial], article)
    end

    if params.has_key?(:storageAgreement)
      article = Ora.buildStorageAgreementData(params[:storageAgreement], article)
    end

    # Remove blank assertions for rights activity and build
    if params.has_key?(:license) || params.has_key?(:rights)
      article = Ora.buildRightsActivity(params, article)
    end

    #remove_blank_assertions for publication activity and build
    if params.has_key?(:publication)
      article = Ora.buildPublicationActivity(params[:publication], article)
    end
    # get the publication date to calculate embargo dates for access rights
    if article.class.to_s != "DatasetAgreement"
      datePublished = nil
      if !article.publication[0].nil? && !article.publication[0].datePublished.nil?
        datePublished = article.publication[0].datePublished.first
      end
    end

    # Remove blank assertions for dataset access rights and build
    if params.has_key?(:accessRights)
      #ar = Ora.validateEmbargoDates(params[:accessRights], "info:fedora/#{article.id}", datePublished)
      article = Ora.buildAccessRights(params[:accessRights], article, datePublished)
    end

    # Remove blank assertions for internal relations and build
    if params.has_key?(:hasPart)
      article = Ora.buildInternalRelations(params[:hasPart], article, datePublished, contents)
    end

    #remove_blank_assertions for external relations and build
    if params.has_key?(:qualifiedRelation)
      article = Ora.buildExternalRelations(params[:qualifiedRelation], article)
    end

    #remove_blank_assertions for funding activity and build
    if params.has_key?(:funding)
      article = Ora.buildFundingActivity(params[:funding], article)
    end

    #remove_blank_assertions for creation activity and build
    if params.has_key?(:creation)
      article = Ora.buildCreationActivity(params[:creation], article)
    end

    #Remove blank assertions for validity date and build
    if params.has_key?(:valid)
      article = Ora.buildValidityDate(params[:valid], article)
    end

    #Remove blank assertions for invoice details and build
    if params.has_key?(:invoice)
      article = Ora.buildInvoiceData(params[:invoice], article)
    end

    article
  end

end
