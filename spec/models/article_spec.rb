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
  
  attributes_hash = {
    "title" => "Sample article title",
    "subtitle" => "Subtitle of article",
    "copyright_holder" => {
      "display_name" => "Will Smith",
      "role" => "Copyright Holder",
      "rights_ownership" => "Sole authorship",
      "third_party_copyright" => "Contains Third Party copyright",
    },
    "type" => "Journal article",
    "language" => "English",
    "physical_description" => {
      "status" => "Published",
      "peer_reviewed" => "Peer reviewed",
      "version" => "Publisher's version",
    },
    "subject" => ["History of the book", "English Language and Literature"],
    "keyword" => ["Dorothea Herbert", "life-writing", "18th century writing", "women's writing"],
    "license" => "cc-0",
    "doi" => "10.00/xxxx",
    "urn" => "uuid:01234567-89ab-cdef-0123-456789abcdef",
    "note" => "This paper is not currently available",
    "related_item" => {
       "title" => "My related journal",
       "location" => "http://journals.iucr.org/s/",
       "note" => "Other version"
    },
    "abstract" => "The abstract for the paper",
    "journal_title" => "Sample host Journal title",
    "journal_volume" => "20",
    "journal_issue" => "1",
    "start_page" => "200",
    "end_page" => "204",
    "page_numbers" => "200-204",
    "publication_date" => "1967-11-01",
    "creation_date" => "2012",
    "copyright_date" => "2012-04",
    "person" => {
      "first_name" => "Jada",
      "last_name" => "Smith",
      "terms_of_address" => "Prof",
      "display_name" => "Smith, J",
      "role" => "Supervisor",
      "webauth" => "zyxw4567",
      "pid" => "uuid:1bcbd111-1477-412c-960e-453ce7f97d34",
      "affiliation" => "some 2 place"
    }
  }


  it "should have the attributes of a journal article and support update_attributes" do
    #@article.update_attributes( attributes_hash )
    @article.pid = "uuid:01234567-89ab-cdef-0123-456789abcdef"
    @article.urn = "uuid:01234567-89ab-cdef-0123-456789abcdef"
    @article.title = "Sample article title updated"
    @article.subtitle = "Subtitle of article updated"
    @article.abstract = "The abstract for the paper updated"
    @article.journal_title = "The Journal of Cool"
    @article.journal_volume = "3"
    @article.journal_issue = "2"
    @article.start_page = "25"
    @article.end_page = "30"
    @article.page_numbers = "200-204"
    @article.agent_first_name = ["Will", "Jada"]
    @article.agent_last_name = ["", "Smithsonian"]
    @article.agent_terms_of_address = "Mr"
    @article.agent_display_name = "Smith, W"
    @article.agent_role = ["Author", "Supervisor"]
    @article.agent_webauth = "abcdefgh"
    @article.agent_pid = "area-llylon-gide-ntif-ier"
    @article.agent_institution = "Oxford"
    @article.agent_faculty = "MSD"
    @article.agent_research_group = "wwf"
    @article.agent_oxford_college = "Anne's"
    #@article.agent_affiliation = "Rich and famous"
    @article.agent_funder = "warner"
    @article.agent_grant_number = "xioi"
    @article.agent_website = "example.com"
    @article.agent_email = "will@example.com"
    @article.agent_rights_ownership = "I me my"
    @article.agent_third_party_copyright = "never"
    @article.type = "Journal article"
    @article.language = "English"
    @article.license = "cc-0"
    @article.doi = "10.00/xxxx"
    @article.note = "This paper is not currently available"
    @article.publication_date = "1967-11-01"
    @article.creation_date = "2012"
    @article.copyright_date = "2012-04"
    @article.subject = "Film history"
    @article.keyword = ["actor", "museum"]
    #@article.person = person0

    # These attributes have been marked "unique" in the call to delegate, which causes the results to be singular
    @article.pid.should == "uuid:01234567-89ab-cdef-0123-456789abcdef"
    @article.urn.should == "uuid:01234567-89ab-cdef-0123-456789abcdef"
    @article.title.should == "Sample article title updated"
    @article.subtitle.should == "Subtitle of article updated"
    @article.abstract.should == "The abstract for the paper updated"
    @article.license.should == "cc-0"
    @article.doi.should == "10.00/xxxx"
    @article.urn.should == "uuid:01234567-89ab-cdef-0123-456789abcdef"
    @article.note.should == "This paper is not currently available"
    @article.publication_date.should == "1967-11-01"
    @article.creation_date.should == attributes_hash["creation_date"]
    @article.copyright_date.should == attributes_hash["copyright_date"]

    # These attriutes test nested hashes
    #@article.organisation.should == [attributes_hash["organisation"]]
    #@article.copyright_holder.should == [attributes_hash["copyright_holder"]]
    #@article.physical_description.should == attributes_hash["physical_description"]
    #@article.subject.should == ["History of the book", "English Language and Literature"]
    #@article.keyword.should == ["Dorothea Herbert", "life-writing", "18th century writing", "women's writing"]

    # These attributes have not been marked "unique" in the call to the delegate, which causes the results to be arrays
    @article.journal_title.should == "The Journal of Cool"
    @article.journal_volume.should == "3"
    @article.journal_issue.should == "2"
    @article.start_page.should == "25"
    @article.end_page.should == "30"
    @article.page_numbers.should == attributes_hash["page_numbers"]
    @article.agent_first_name.should == ["Will", "Jada"]
    @article.agent_last_name.should == ["", "Smithsonian"]
    @article.agent_terms_of_address.should == ["Mr"]
    @article.agent_display_name.should == ["Smith, W", ""] #This seems incorrect
    #@article.agent_display_name.should == ["Smith, W"]
    @article.agent_role.should == ["Author", "Supervisor"]
    @article.agent_webauth.should == ["abcdefgh"]
    @article.agent_pid.should == ["area-llylon-gide-ntif-ier"]
    @article.agent_institution.should == ["Oxford"]
    @article.agent_faculty.should == ["MSD"]
    @article.agent_research_group.should == ["wwf"]
    @article.agent_oxford_college.should == ["Anne's"]
    #@article.agent_affiliation.should == ["Rich and famous"]
    @article.agent_funder.should == ["warner"]
    @article.agent_grant_number.should == ["xioi"]
    @article.agent_website.should == ["example.com"]
    @article.agent_email.should == ["will@example.com"]
    @article.agent_rights_ownership.should == ["I me my"]
    @article.agent_third_party_copyright.should == ["never"]

    #@article.descMetadata.person.first_name.should == ["Will", "Jada"]
    @article.descMetadata.person.first_name.should == ["Will"]
    @article.descMetadata.person(0).first_name.should == "Will"
    @article.descMetadata.person.first_name.should == ["Will", "Jada"]

    @article.type.should == ["Journal article"]
    @article.language.should == ["English"]
    @article.subject.should == ["Film history"]
    @article.keyword.should == ["actor", "museum"]

  end
  
end
