require "datastreams/person_rdf_datastream"
require "oxford_terms"
require "rdf"

class Person < ActiveFedora::Base
  #include Sufia::GenericFile
  has_metadata :name => "descMetadata", :type => PersonRdfDatastream
end
