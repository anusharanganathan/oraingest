module RDF
  class PRO < RDF::Vocabulary("http://purl.org/spar/pro/")
    property :PublishingRole
    property :Role
    property :RoleInTime
    property :holdsRoleInTime
    property :isDocumentContextFor
    property :isOrganizationContextFor
    property :isPersonContextFor
    property :isRelatedToRoleInTime
    property :isHeldBy
    property :isRoleIn
    property :relatesToEntity
    property :relatesToDocument
    property :relatesToOrganization
    property :relatesToPerson
    property :withRole
    property :archivist
    property :author
    property :biographer
    property :blogger
    property :compiler
    property :contributor
    property :critic
    property :distributor
    property :editor
    property :illustrator
    property :journalist
    property :librarian
    property :printer
    property :producer
    property :publisher
    property :reader
    property :reviewer
    property :translator
  end
end
