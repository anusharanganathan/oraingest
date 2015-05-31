require 'id_service'

module DoiMethods
  extend ActiveSupport::Concern

  def doi(mint=true)
    doi = nil
    if self.class.model_name.to_s != "Dataset"
      return doi
    end
    if (self.publication.first && 
        self.publication.first.hasDocument.first &&
        !self.publication.first.hasDocument.first.doi.first.blank?)
      doi = self.publication.first.hasDocument.first.doi.first
    elsif mint
      doi = Sufia::Noid.noidify(Sufia::IdService.mint_doi)
      doi = Sufia::Noid.doize(doi)
    end
    doi
  end

  def doi_requested?
    status = false
    if self.workflows.first && self.workflows.first.involves.any?
      self.workflows.first.involves.each do |event|
        if event.include?("Register doi")
          status = true
        end
      end
    end
    status
  end

  def doi_data
    if self.class.model_name.to_s != "Dataset"
      return {}
    end
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
    unless self.title.first.blank?
      doi_data[:title] = self.title.first
    end
    # identifier
    begin
      doi_data[:identifier] = self.publication.first.hasDocument.first.doi.first
    rescue
      doi_data[:identifier] = ""
    end
    # publisher
    begin
      doi_data[:publisher] = self.publication.first.publisher.first.agent.first.name.first
    rescue
      doi_data[:publisher] = "University of Oxford"
    end
    # publication year
    begin
      doi_data[:publicationYear] = self.publication.first.datePublished.first
    rescue
      doi_data[:publicationYear] = Time.now.year
    end
    # creator and contributor
    if self.creation.first
      self.creation.first.creator.each do |cr|
        if cr.agent.first && !cr.agent.first.name.first.blank?
          c = { name: cr.agent.first.name.first }
          if (cr.agent.first.affiliation.first &&
             !cr.agent.first.affiliation.first.name.first.blank?)
            c[:affiliation] = cr.agent.first.affiliation.first.name.first
          end
          if cr.role.first.to_s == "http://purl.org/dc/terms/creator"
            doi_data[:creator] << c
          else
            if (Sufia.config.role_labels.include?(cr.role.first) &&
               contributorTypes.include?(Sufia.config.role_labels[cr.role.first]))
              c[:type] = Sufia.config.role_labels[cr.role.first]
            elsif contributorTypes.include?(cr.role.first)
              c[:type] = cr.role.first
            else
              c[:type] = "Other"
            end
            doi_data[:contributor] << c
          end
        end
      end
    end
    # subject
    self.subject.each do |s|
      sh = {}
      unless s.subjectLabel.first.blank?
        sh[:subject] = s.subjectLabel.first
      end
      unless s.subjectAuthority.first.blank?
        sh[:schemeUri] = s.subjectAuthority.first.rpartition("/").first
      end
      unless s.subjectScheme.first.blank?
        sh[:scheme] = s.subjectScheme.first
      end
      if sh.any?
        doi_data[:subject] << sh
      end
    end
    # digitalSize
    unless self.digitalSize.first.blank?
      doi_data[:digitalSize] = self.digitalSize.first
    end
    # version
    unless self.version.first.blank?
      doi_data[:version] = self.version.first
    end
    # rights
    if self.license.any?
      self.license.each do |l|
        r =  {}
        unless l.licenseStatement.first.blank?
          r[:rights] = l.licenseStatement.first
        else
          unless l.licenseLabel.first.blank?
            r[:rights] = l.licenseLabel.first
          end
        end
        unless l.licenseURI.first.blank?
          r[:rightsUri] = l.licenseURI.first
        end
        if r.any?
          doi_data[:rights] << r
        end
      end
    end
    # abstract
    unless self.abstract.first.blank?
      doi_data[:description] << {description: self.abstract.first, type: "Abstract"}
    end
    doi_data
  end

  def normalize_doi(value, with_prefix=true)
    resolver_url = Sufia.config.doi_credentials.fetch(:resolver_url)
    value = value.to_s.strip.
      sub(/\A#{resolver_url}/, '').
      sub(/\s*doi\s*:*\s*/i, '')
    if with_prefix
      "doi:#{value}"
    else
      value
    end
  end

  def remote_uri_for(identifier)
    resolver_url = Sufia.config.doi_credentials.fetch(:resolver_url)
    URI.parse(File.join(resolver_url, normalize_doi(identifier, with_prefix=false)))
  end

end

