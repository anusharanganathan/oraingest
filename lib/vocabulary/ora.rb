module RDF
  class ORA < RDF::Vocabulary("http://vocab.ox.ac.uk/ora#")
    property :affiliation
    property :annotation
    # copyright
    property :copyrightNote
    # payment
    property :apcPaid
    property :monetaryValue
    property :monetaryStatus
    # OA and ref related
    property :oaReason
    property :oaStatus
    property :refException
    # Dataset agreement related terms
    property :agreementStatus
    property :agreementType
    # Data related
    property :dateCollected
    property :dataContributor
    property :dataSteward
    property :dataStorageDetails
    property :dataStorageSilo
    property :digitalSize
    property :digitalSizeAllocated
    property :locator
    property :storageAgreement
    # Embargo related
    property :embargoStatus
    property :embargoStart
    property :embargoEnd
    property :embargoReason
    property :embargoRelease
    # Prov ontology associations
    property :DataSteward
    property :DataStorageAgreement
    property :TitularAgent
    property :hadCreationActivity
    property :hadPublicationActivity
    property :hadTitularActivity
    property :hasAgreement
    property :hasDataset
    property :hasDataManagementPlan
    property :hasInvoice
    property :isPartOfSeries
    # workflow
    property :reviewStatus
    # Thesis
    property :thesisDegreeLevel
    # roles
    property :adapter
    property :author
    property :copyrightHolder
    property :designatedDataSteward
    property :thesisSupervisor
    property :departmentalAdministrator
    property :depositor
    property :editor
    property :examiner
    property :funder
    property :headOfDepartment
    property :headOfFaculty
    property :headOfResearchGroup
    property :dataManager
    property :laboratoryManager
    property :performer
    property :principalInvestigator
    property :researcher
    property :reviewer
    property :sponsor
    property :subjectLibrarian
    property :supervisor
    property :translator
    # funding
    property :hasFundingAward
  end
end
