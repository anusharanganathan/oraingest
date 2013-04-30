require 'spec_helper'

describe Article do
  
  before(:each) do
    # This gives you a test article object that can be used in any of the tests
    @article = Article.new
  end
  
  it "should have the specified datastreams" do
    # Check for descMetadata datastream with MODS in it
    @article.datastreams.keys.should include("descMetadata")
    @article.descMetadata.should be_kind_of ArticleModsDatastream
    # Check for rightsMetadata datastream
    @article.datastreams.keys.should include("rightsMetadata")
    @article.rightsMetadata.should be_kind_of Hydra::Datastream::RightsMetadata
  end
  
  #person1 = {
  #    "first_name" => "Will",
  #    "last_name" => "Smith",
  #    "terms_of_address" => "Dr",
  #    "display_name" => "Smith, W",
  #    "role" => "author",
  #    "webauth" => "abcd1234",
  #    "pid" => "uuid:1bcbd111-1477-412c-960e-453ce7f97dc5",
  #    "institution" => "University of Oxford",
  #    "faculty" => "Humanities Division - English Language and Literature",
  #    "oxford_college" => "Linacre College",
  #    "affiliation" => "",
  #    "funder" => "Leverhulme Trust",
  #    "grant_number" => "ax-1234",
  #    "website" => "example.com",
  #    "email" => "will.smith@example.com"
  #}
  #person2 = {
  #    "first_name" => "Jada",
  #   "last_name" => "Smith",
  #    "terms_of_address" => "Prof",
  #    "display_name" => "Smith, J",
  #    "role" => "Supervisor",
  #    "webauth" => "zyxw4567",
  #    "pid" => "uuid:1bcbd111-1477-412c-960e-453ce7f97d34",
  #    "affiliation" => "some place"
  #}
  attributes_hash = {
    "title" => "Sample article title",
    "subtitle" => "Subtitle of article",
    #"person" => {
    #  "first_name" => "Will",
    #  "last_name" => "Smith",
    #  "terms_of_address" => "Dr",
    #  "display_name" => "Smith, W",
    #  "role" => "author",
    #  "webauth" => "abcd1234",
    #  "pid" => "uuid:1bcbd111-1477-412c-960e-453ce7f97dc5",
    #  "institution" => "University of Oxford",
    #  "faculty" => "Humanities Division - English Language and Literature",
    #  "oxford_college" => "Linacre College",
    #  "affiliation" => "",
    #  "funder" => "Leverhulme Trust",
    #  "grant_number" => "ax-1234",
    #  "website" => "example.com",
    #  "email" => "will.smith@example.com"
    #  },
    #"person"[1] => {
    #  "first_name" => "Jada",
    #  "last_name" => "Smith",
    #  "terms_of_address" => "Prof",
    #  "display_name" => "Smith, J",
    #  "role" => "Supervisor",
    #  "webauth" => "zyxw4567",
    #  "pid" => "uuid:1bcbd111-1477-412c-960e-453ce7f97d34",
    #  "affiliation" => "some place"
    #  },
    #"organisation"[0] => {
    #  "display_name" => "Name of Publisher",
    #  "role" => "Publisher",
    #  "website" => "http://www.example.org/",
    #},
    #"copyright_holder" => {
    #  "display_name" => "Will Smith",
    #  "role" => "Copyright Holder",
    #  "rights_ownership" => "Sole authorship",
    #  "third_party_copyright" => "Contains Third Party copyright",
    #},
    "type" => "Journal article",
    "language" => "English",
    #"physical_description" => {
    #  "status" => "Published",
    #  "peer_reviewed" => "Peer reviewed",
    #  "version" => "Publisher's version",
    #},
    #"subject" => ["History of the book", "English Language and Literature"],
    #"keyword" => ["Dorothea Herbert", "life-writing", "18th century writing", "women's writing"],
    "license" => "cc-0",
    "doi" => "10.00/xxxx",
    "urn" => "uuid:01234567-89ab-cdef-0123-456789abcdef",
    "note" => "This paper is not currently available",
    #"related_item" => {
    #   "title" => "My related journal",
    #   "location" => "http://journals.iucr.org/s/",
    #   "name" => "Other version"
    #},
    "abstract" => "The abstract for the paper",
    "journal_title" => "Sample host Journal title",
    "journal_volume" => "20",
    "journal_issue" => "1",
    "start_page" => "200",
    "end_page" => "204",
    "page_numbers" => "200-204",
    "publication_date" => "1967-11-01",
    "creation_date" => "2012",
    "copyright_date" => "2012-04"
  }

  it "should have the attributes of a journal article and support update_attributes" do
    #@article.update_attributes( attributes_hash )
    @article.title = "Sample article title updated"
    @article.subtitle = "Subtitle of article updated"
    @article.type = "Journal article"
    @article.language = "English"
    @article.license = "cc-0"
    @article.doi = "10.00/xxxx"
    @article.urn = "uuid:01234567-89ab-cdef-0123-456789abcdef"
    @article.pid = "uuid:01234567-89ab-cdef-0123-456789abcdef"
    @article.note = "This paper is not currently available"
    @article.abstract = "The abstract for the paper updated"
    @article.journal_title = "The Journal of Cool"
    @article.journal_volume = "3"
    @article.journal_issue = "2"
    @article.start_page = "25"
    @article.end_page = "30"
    @article.page_numbers = "200-204"
    @article.publication_date = "1967-11-01"
    @article.creation_date = "2012"
    @article.copyright_date = "2012-04"
    
    # These attributes have been marked "unique" in the call to delegate, which causes the results to be singular
    @article.title.should == "Sample article title updated"
    @article.subtitle.should == "Subtitle of article updated"

    #@article.person.should == {
    #    "first_name" => "Will",
    #    "last_name" => "Smith",
    #    "terms_of_address" => "Dr",
    #    "display_name" => "Smith, W",
    #    "role" => "author",
    #    "webauth" => "abcd1234",
    #    "pid" => "uuid:1bcbd111-1477-412c-960e-453ce7f97dc5",
    #    "institution" => "University of Oxford",
    #    "faculty" => "Humanities Division - English Language and Literature",
    #    "oxford_college" => "Linacre College",
    #    "affiliation" => "",
    #    "funder" => "Leverhulme Trust",
    #    "grant_number" => "ax-1234",
    #    "website" => "example.com",
    #    "email" => "will.smith@example.com"
    #}
    #},
    #{
    #    "first_name" => "Jada",
    #    "last_name" => "Smith",
    #    "terms_of_address" => "Prof",
    #    "display_name" => "Smith, J",
    #    "role" => "Supervisor",
    #    "webauth" => "zyxw4567",
    #    "pid" => "uuid:1bcbd111-1477-412c-960e-453ce7f97d34",
    #    "affiliation" => "some place"
    #}]
    #@article.organisation.should == [attributes_hash["organisation"]]
    #@article.copyright_holder.should == [attributes_hash["copyright_holder"]]

    #@article.type.should == "Journal article"
    @article.language.should == ["English"]
    #@article.physical_description.should == attributes_hash["physical_description"]
    #@article.subject.should == ["History of the book", "English Language and Literature"]
    #@article.keyword.should == ["Dorothea Herbert", "life-writing", "18th century writing", "women's writing"]
    @article.license.should == "cc-0"
    @article.doi.should == "10.00/xxxx"
    @article.urn.should == "uuid:01234567-89ab-cdef-0123-456789abcdef"
    @article.note.should == "This paper is not currently available"
    @article.abstract.should == "The abstract for the paper updated"
    # These attributes have not been marked "unique" in the call to the delegate, which causes the results to be arrays
    @article.journal_title.should == "The Journal of Cool"
    @article.journal_volume.should == "3"
    @article.journal_issue.should == "2"
    @article.start_page.should == "25"
    @article.end_page.should == "30"
    @article.page_numbers.should == attributes_hash["page_numbers"]

    @article.publication_date.should == "1967-11-01"
    @article.creation_date.should == attributes_hash["creation_date"]
    @article.copyright_date.should == attributes_hash["copyright_date"]
  end
  
end
