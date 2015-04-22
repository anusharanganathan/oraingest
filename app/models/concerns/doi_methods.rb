require 'id_service'

module DoiMethods
  extend ActiveSupport::Concern

  def doi(mint=true)
    doi = nil
    if (!self.publication.nil? && !self.publication[0].nil? &&
       !self.publication[0].hasDocument.nil? && !self.publication[0].hasDocument[0].nil? &&
       !self.publication[0].hasDocument[0].doi.nil? && !self.publication[0].hasDocument[0].doi[0].blank?)
      doi = self.publication[0].hasDocument[0].doi[0]
    elsif mint
      doi = Sufia::Noid.noidify(Sufia::IdService.mint_doi)
      doi = Sufia::Noid.doize(doi)
    end
    doi
  end

  def doi_requested
    status = false
    if !self.workflows.nil? && !self.workflows.first.nil? && !self.workflows.first.involves.nil?
      self.workflows.first.involves.each do |event|
        if event.include?("Register doi")
          status = true
        end
      end
    end
    status
  end

  def doi_data
    contributorTypes = [
      "ContactPerson",
      "DataCollector",
      "DataCurator",
      "DataManager",
      "Distributor",
      "Editor",
      "Funder",
      "HostingInstitution",
      "Other",
      "Producer",
      "ProjectLeader",
      "ProjectManager",
      "ProjectMember",
      "RegistrationAgency",
      "RegistrationAuthority",
      "RelatedPerson",
      "ResearchGroup",
      "RightsHolder",
      "Researcher",
      "Sponsor",
      "Supervisor",
      "WorkPackageLeader",
    ]
    
    doi_data = {
      target: "http://ora.ox.ac.uk/objects/#{self.id.to_s}",
      creator: [],
      contributor: [],
      subject: [],
      resourceType: "Dataset",
      resourceTypeGeneral: "Dataset",
      rights: [],
      description: []
    }
    # title
    if !self.title.empty?
      doi_data[:title] = self.title[0]
    end
    # identifier
    begin
      doi_data[:identifier] = self.publication[0].hasDocument[0].doi[0]
    rescue
      doi_data[:identifier] = ""
    end
    # publisher
    begin
      doi_data[:publisher] = self.publication[0].publisher[0].agent[0].name[0]
    rescue
      doi_data[:publisher] = "University of Oxford"
    end
    # publication year
    begin
      doi_data[:publicationYear] = self.publication[0].datePublished[0]
    rescue
      doi_data[:publicationYear] = Time.now.year
    end
    # creator and contributor
    self.creation[0].creator.each do |cr|
      if !cr.agent.nil? && !cr.agent[0].nil? && !cr.agent[0].name.nil? && !cr.agent[0].name[0].empty?
        c = { name: cr.agent[0].name[0] }
        if !cr.agent[0].affiliation.nil? && !cr.agent[0].affiliation[0].nil? && !cr.agent[0].affiliation[0].name.nil? && !cr.agent[0].affiliation[0].name[0].empty?
          c[:affiliation] = cr.agent[0].affiliation[0].name[0]
        end
        if cr.role[0].to_s == "http://purl.org/dc/terms/creator"
          doi_data[:creator] << c
        else
          if Sufia.config.role_labels.include?(cr.role[0]) && contributorTypes.include?(Sufia.config.role_labels[cr.role[0]])
            c[:type] = Sufia.config.role_labels[cr.role[0]]
          elsif contributorTypes.include?(cr.role[0])
            c[:type] = cr.role[0]
          else
            c[:type] = "Other"
          end
          doi_data[:contributor] << c
        end
      end
    end
    # subject
    self.subject.each do |s|
      sh = {}
      if !s.subjectLabel.empty? && !s.subjectLabel[0].empty?
        sh[:subject] = s.subjectLabel[0]
      end
      if !s.subjectAuthority.empty? && !s.subjectAuthority[0].empty?
        sh[:schemeUri] = s.subjectAuthority[0].rpartition("/")[0]
      end
      if !s.subjectScheme.empty? && !s.subjectScheme[0].empty?
        sh[:scheme] = s.subjectScheme[0]
      end
      if !sh.empty?
        doi_data[:subject] << sh
      end
    end
    # digitalSize
    if !self.digitalSize.empty?
      doi_data[:digitalSize] = self.digitalSize[0]
    end
    # format
    if !self.format.empty?
      doi_data[:format] = self.format[0]
    end
    # version
    if !self.version.empty?
      doi_data[:version] = self.version[0]
    end
    # rights
    if !self.license.nil?
      self.license.each do |l|
        r =  {}
        if !l.licenseStatement.empty? && !l.licenseStatement[0].empty?
          r[:rights] = l.licenseStatement[0]
        elsif !l.licenseLabel.empty? && !l.licenseLabel[0].empty?
          r[:rights] = l.licenseLabel[0]
        end
        if !l.licenseURI.empty? && !l.licenseURI[0].empty?
          r[:rightsUri] = l.licenseURI[0]
        end
        if !r.empty?
          doi_data[:rights] << r
        end
      end
    end
    # abstract
    if !self.abstract.empty?
      doi_data[:description] << {description: self.abstract[0], type: "Abstract"}
    end
    doi_data
  end

  def normalize_doi(value)
    resolver_url = Sufia.config.doi_credentials.fetch(:resolver_url)
    value.to_s.strip.
        sub(/\A#{resolver_url}/, '').
        sub(/\A\s*doi:\s+/, 'doi:').
        sub(/\A(\d)/, 'doi:\1')
  end

  def remote_uri_for(identifier)
    resolver_url = Sufia.config.doi_credentials.fetch(:resolver_url)
    URI.parse(File.join(resolver_url, normalize_doi(identifier)))
  end

end


