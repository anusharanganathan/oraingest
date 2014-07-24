module RDF
  class FRAPO < RDF::Vocabulary("http://purl.org/cerif/frapo/")
    property :hasGrantNumber
    property :isFundingAgencyFor
    property :awards
    property :Grant
    property :funds
    property :isOutputOf
    property :FundingAgency
  end
end
