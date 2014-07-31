module RDF
  class ORA < RDF::Vocabulary("http://vocab.ox.ac.uk/ora#")
    property :reviewStatus
    property :copyrightNote
    property :thesisDegreeLevel
    property :rightsHolderGroup
    property :embargoStatus
    property :embargoStart
    property :embargoEnd
    property :embargoReason
    property :embargoRelease
    property :affiliation
    property :author
    property :supervisor
    property :examiner
    property :hadCreationActivity
    property :hadPublicationActivity
    property :annotation
    property :oaReason
    property :oaStatus
    property :apcPaid
    property :refException
    property :isPartOfSeries
  end
end
