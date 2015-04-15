module DoiMethods
  extend ActiveSupport::Concern

  def doi_data
    doi_data = {
      target: "http://ora.ox.ac.uk/objects/#{self.id.to_s}",
      creators: [],
      contributors: [],
      subjects: [],
      resourceType: "Dataset",
      resourceTypeGeneral: "Dataset",
      rights: [],
      descriptions: []
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
          doi_data[:creators] << c
        else
          if Sufia.config.role_labels.include?(cr.role[0])
            c[:type] = Sufia.config.role_labels[cr.role[0]]
          else
            c[:type] = cr.role[0]
          end
          doi_data[:contributors] << c
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
        doi_data[:subjects] << sh
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
      doi_data[:descriptions] << {description: self.abstract[0], type: "Abstract"}
    end
    doi_data
  end

end


