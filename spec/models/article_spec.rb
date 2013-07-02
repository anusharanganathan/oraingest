require 'spec_helper'

describe Article do
  
  before(:each) do
    # This gives you a test article object that can be used in any of the tests
    @article = Article.new
  end
  
  it "should save" do
    puts @article.datastreams["RELS-EXT"].to_rels_ext
    @article.save.should be_true
    @article.errors.should be_empty
  end
  
  it "should have the specified datastreams" do
    # Check for descMetadata datastream with MODS in it
    @article.datastreams.keys.should include("descMetadata")
    @article.descMetadata.should be_kind_of Datastream::ArticleModsDatastream
    # Check for rightsMetadata datastream
    @article.datastreams.keys.should include("rightsMetadata")
    @article.rightsMetadata.should be_kind_of Hydra::Datastream::RightsMetadata
    # Check for recordStatus datastream
    @article.datastreams.keys.should include("recordStatus")
    @article.descMetadata.should be_kind_of Datastream::recordStatusModsDatastream
  end
  
  attributes_hash = {
    :title => "Sample article title",
    :subtitle => "Subtitle of article",
    :person => [{
      :last_name => "Smith",
      :first_name => "Will",
      :display_name => "Smith, W",
      :terms_of_address => "Dr",
      :email => "will.smith@example.com",
      :institution => "University of Oxford",
      :faculty => "Humanities Division - English Language and Literature",
      :oxford_college => "Linacre College",
      :researchGroup => "Name of research group",
      :roleterm => {:text=>"author"},
      :funder => "Leverhulme Trust",
      :grant_number => "Grant number for author funding",
      :website => "http://example.com/author1",
      :uuid => "uuid:1bcbd111-1477-412c-960e-453ce7f97dc5",
      :webauth => "abcd1234"
      },{
      :last_name => "Jones",
      :first_name => "Jack",
      :display_name => "Jones, J",
      :terms_of_address => "Mr",
      :email => "jack.jones@example.com",
      :institution => "St Andrews University",
      :faculty => "English Department",
      :researchGroup => "Name of 2nd research group",
      :roleterm => {:text=>"author"},
      :funder => "National Trust",
      :grant_number => "Grant number for 2nd author funding",
      :website => "http://example.com/author2",
      :uuid => "uuid:2bcbd222-2588-523d-960e-453ce7f97dc5",
      :webauth => "abcd5678"
      },{
      :last_name => "Smith",
      :first_name => "Jada",
      :display_name => "Smith, J",
      :terms_of_address => "Prof",
      :roleterm => {:text=>"supervisor"}
      }
    ],
    :copyright_holder => [{
      :display_name => "Will Smith",
      :roleterm => {:text=>"Coyright Holder"},
      :rights_ownership => "Sole authorship",
      :third_party_copyright => "Contains Third Party copyright"
    }],
    :organisation =>[{
      :display_name => "Name of Publisher",    
      :roleterm => {:text=>"Publisher"},
      :website => "http://www.example.org/"
    }],
    :type_of_resource => "text",
    :type => "Journal article",
    :creation_date => "2013",
    :publication_date => "2012-03",
    :copyright_date => "2012-04",
    :language => "English",
    :digital_origin => "born digital",
    :status => "Published",
    :peer_reviewed => "Peer reviewed",
    :version => "Publisher's version",
    :journal_title => "Sample host Journal title",
    :journal_volume => "20",
    :journal_issue => "1",
    :start_page => "200",
    :end_page => "204",
    :page_numbers => "200-204",
    :related_item => [{
      :location => {:url => "http://journals.iucr.org/s/"},
      :type => "otherVersion"
    }, {
      :location => {:url => "http://example.org/referenced_article/"},
      :type => "references"
    }],
    :abstract => "The abstract for the paper",
    :note => "This paper is not currently available",
    :subject => ["History of the book", "English Language and Literature"],
    :keyword => ["Dorothea Herbert", "life-writing", "18th century writing", "women's writing"],
    :uuid => "uuid:01234567-89ab-cdef-0123-456789abcdef",
    :urn => "uuid:01234567-89ab-cdef-0123-456789abcdef",
    :doi => "10.00/xxxx",
    :license => "cc-0"
  }


  it "should have the attributes of a journal article and support update_attributes" do
    #@article.update_attributes( attributes_hash )
    @article.uuid = "uuid:01234567-89ab-cdef-0123-456789abcdef"
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
    @article.uuid.should == "uuid:01234567-89ab-cdef-0123-456789abcdef"
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
    @article.agent_display_name.should == ["Smith, W"]
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
    @article.descMetadata.person(0).first_name.should == ["Will"]
    debugger
    @article.descMetadata.person.first_name.should == ["Will", "Jada"]

    @article.type.should == ["Journal article"]
    @article.language.should == ["English"]
    @article.subject.should == ["Film history"]
    @article.keyword.should == ["actor", "museum"]

  end
  
end
