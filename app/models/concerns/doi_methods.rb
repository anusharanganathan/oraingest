require 'id_service'

module DoiMethods
  extend ActiveSupport::Concern

  def doi(mint=true)
    doi = nil
    if self.model_klass != "Dataset"
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
        if event.include?(Sufia.config.doi_event)
          status = true
        end
      end
    end
    status
  end

  def doi_registered?
    status = false
    if self.workflows.first && self.workflows.first.all_statuses
      if self.workflows.first.all_statuses.include?(Sufia.config.doi_status)
        status = true
      end
    end
    status
  end

  def request_doi
    doi_s = self.doi(mint=false)
    unless doi_s.blank?
      return doi_s
    end
    doi_s = self.doi(mint=true)
    unless doi_s
      return doi_s
    end
    if self.publication.blank?
      args = {'id' => "info:fedora/%s#publicationActivity" % self.id, :type => RDF::PROV.Activity}
      self.publication.build(args)
    end
    if self.publication[0].hasDocument.blank?
      args = {'id' => "info:fedora/%s#publicationDocument" % d.id}
      self.publication[0].hasDocument.build(args)
    end
    self.publication[0].hasDocument[0].doi = doi_s
    doi_s
  end

  def doi_data
    if self.model_klass != "Dataset"
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
          if cr.role.include?(RDF::DC.creator)
            doi_data[:creator] << c
          else
            matching_roles1 = cr.role.map { |role| Sufia.config.role_labels[role] if Sufia.config.role_labels.include?(role) && contributorTypes.include?(Sufia.config.role_labels[role]) }
            matching_roles2 = cr.role.select { |role| contributorTypes.include?(role) }
            if matching_roles1
              c[:type] = matching_roles1.first
            elsif matching_roles2
              c[:type] = matching_roles2.first
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

