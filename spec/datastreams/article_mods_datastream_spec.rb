require 'spec_helper'
#require 'pp'
describe ArticleModsDatastream do
  before(:each) do
    @mods = fixture("article_mods_sample.xml")
    @ds = ArticleModsDatastream.from_xml(@mods)
  end
  it "should expose bibliographic info for journal articles with explicit terms and simple proxies" do
    @ds.mods.title_info.main_title.should == ["Sample article title"]
    @ds.title.should == ["Sample article title"]
    @ds.mods.title_info.sub_title.should == ["Subtitle of article"]
    @ds.subtitle.should == ["Subtitle of article"]
    @ds.abstract.should == ["The abstract for the paper"]
    @ds.journal.title_info.main_title.should == ["Sample host Journal title"]   
    @ds.journal_title.should == ["Sample host Journal title"]   
    @ds.publication_date.should == ["2012-03"]
    @ds.copyright_date.should == ["2012-04"]
    @ds.journal.part.volume.number.should == ["20"]
    @ds.journal_volume.should == ["20"]
    @ds.journal.part.issue.number.should == ["1"]
    @ds.journal_issue.should == ["1"]
    @ds.journal.part.pages.start.should == ["200"]
    @ds.start_page.should == ["200"]
    @ds.journal.part.pages.end.should == ["204"]
    @ds.end_page.should == ["204"]
    @ds.journal.part.pages.list.should == ["200-204"]
    @ds.page_numbers.should == ["200-204"]
    @ds.note.should == ["This paper is not currently available"]
    @ds.subject.should == ["History of the book", "English Language and Literature"]
    @ds.keyword.should == ["Dorothea Herbert", "life-writing", "18th century writing", "women's writing"]
    @ds.language == ["English"]
    @ds.type = ["Journal article"]
    @ds.mods.physical_description.status = ["Published"]
    @ds.mods.physical_description.peer_reviewed = ["Peer reviewed"]
    @ds.mods.physical_description.version = ["Publisher's version"]
    @ds.mods.related_item.location.url = ["http://journals.iucr.org/s/"]
    @ds.pid = ["uuid:01234567-89ab-cdef-0123-456789abcdef"]
    @ds.urn = ["uuid:01234567-89ab-cdef-0123-456789abcdef"]
    @ds.doi = ["10.00/xxxx"]
    @ds.license = ["cc-0"]
  end

  
  it "should expose nested/hierarchical metadata" do
    @ds.agent_first_name.should == ["Will","Jada"]
    @ds.person.first_name.should == ["Will","Jada"]
    @ds.person.last_name.should == ["Smith", "Smith"]
    @ds.person.display_name.should == ["Smith, W", "Smith, J"]
    @ds.person.terms_of_address.should == ["Dr", "Prof"]
    @ds.person.email.should == ["will.smith@example.com"]
    @ds.person.institution.should == ["University of Oxford"]
    @ds.person.faculty.should == ["Humanities Division - English Language and Literature"]
    @ds.person.oxford_college.should == ["Linacre College"]
    @ds.person.roleterm.text.should == ["author", "Supervisor"]
    @ds.person.funder.should == ["Leverhulme Trust"]
    @ds.person.pid.should == ["uuid:1bcbd111-1477-412c-960e-453ce7f97dc5"]

    @ds.person(0).first_name.should == ["Will"]
    @ds.person(0).last_name.should == ["Smith"]
    @ds.person(0).roleterm.text.should == ["author"]

    #Debugging - print the values for the following
    #pp @ds.agent
    #pp @ds.person
    #pp @ds.organisation
    #pp @ds.agent(1)

    @ds.organisation.display_name.should == ["Name of Publisher"]
    @ds.organisation.roleterm.text.should == ["Publisher"]
    @ds.organisation.website.should == ["http://www.example.org/"]
 
    @ds.agent(1).display_name.should == ["Will Smith"]
    @ds.agent(1).roleterm.text.should == ["Copyright Holder"]
    @ds.agent(1).rights_ownership.should == ["Sole authorship"]
    @ds.agent(1).third_party_copyright.should == ["Contains Third Party copyright"]
  end
end
