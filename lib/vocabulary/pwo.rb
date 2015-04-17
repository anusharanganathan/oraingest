module RDF
  class PWO < RDF::Vocabulary("http://purl.org/spar/pwo/")
    property :Step
    property :Workflow
    property :hasFirstStep
    property :hasNextStep
    property :hasPreviousStep
    property :hasStep
    property :involvesEvent
    property :isInvolvedInStep
    property :isNeededBy
    property :isProducedBy
    property :isStepOf
    property :needs
    property :produces
  end
end
