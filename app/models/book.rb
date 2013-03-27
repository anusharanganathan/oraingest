class Book < ActiveFedora::Base
  has_metadata 'descMetadata', type: Datastream::BookMetadata

  has_many :pages, :property=> :is_part_of

  delegate :title, to: 'descMetadata'
  delegate :author, to: 'descMetadata'

end
