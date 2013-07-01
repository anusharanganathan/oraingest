require 'spec_helper'
#require 'pp'
describe Datastream::ArticleModsDatastream do
  before(:each) do
    @mods = fixture("article_mods_sample.xml")
    @ds = Datastream::ArticleModsDatastream.from_xml(@mods)
  end
  it "should expose bibliographic info for journal articles with explicit terms and simple proxies" do
    # title and subtitle
    @ds.mods.title_info.main_title.should == ["Sample article title"]
    #Title defined in article model
    #@ds.title.should == ["Sample article title"]
    @ds.mods.title_info.sub_title.should == ["Subtitle of article"]
    @ds.subtitle.should == ["Subtitle of article"]
    # type of resource
    @ds.type_of_resource.should == ["text"]
    # type of work
    @ds.type = ["Journal article"]
    # origin info
    @ds.mods.origin_info.date_created.should == ["2013"]
    @ds.creation_date.should == ["2013"]
    @ds.mods.origin_info.date_issued.should == ["2012-03"]
    @ds.publication_date.should == ["2012-03"]
    @ds.mods.origin_info.copyright_date.should == ["2012-04"]
    @ds.copyright_date.should == ["2012-04"]
    # language
    @ds.language == ["English"]
    # physical description
    @ds.mods.physical_description.digital_origin.should == ["born digital"]
    @ds.mods.physical_description.status.should == ["Published"]
    @ds.mods.physical_description.peer_reviewed.should == ["Peer reviewed"]
    @ds.mods.physical_description.version.should == ["Publisher's version"]
    @ds.digital_origin.should == ["born digital"]
    @ds.status.should == ["Published"]
    @ds.peer_reviewed.should == ["Peer reviewed"]
    @ds.version.should == ["Publisher's version"]
    # journal info - related item - host
    @ds.journal.title_info.main_title.should == ["Sample host Journal title"]   
    @ds.journal_title.should == ["Sample host Journal title"]   
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
    # related item - other version
    @ds.mods.related_item.location.url.should == ["http://journals.iucr.org/s/", "http://example.org/referenced_article/"]
    @ds.related_item_otherVersion.location.url.should == ["http://journals.iucr.org/s/"]
    # TODO: Why is this giving me a wrong value?
    #@ds.related_item_otherVersion.related_item_location.should == ["http://journals.iucr.org/s/"]
    @ds.related_item_references.location.url.should == ["http://example.org/referenced_article/"]
    # abstract
    @ds.abstract.should == ["The abstract for the paper"]
    # note
    @ds.note.should == ["This paper is not currently available"]
    # subject
    @ds.subject.should == ["History of the book", "English Language and Literature"]
    # keyword
    @ds.keyword.should == ["Dorothea Herbert", "life-writing", "18th century writing", "women's writing"]
    @ds.uuid = ["uuid:01234567-89ab-cdef-0123-456789abcdef"]
    @ds.urn = ["uuid:01234567-89ab-cdef-0123-456789abcdef"]
    @ds.doi = ["10.xxxx/xxxx"]
    @ds.license = ["cc-0"]
  end

  
  it "should expose nested/hierarchical metadata" do
    #Debugging - print the values for the following
    #pp @ds.person
    #pp @ds.organisation
    #pp @ds.copyright_holder
    #pp @ds.person(1)

    @ds.person.first_name.should == ["Will", "Jack", "Jada"]
    @ds.person.last_name.should == ["Smith", "Jones", "Smith"]
    @ds.person.display_name.should == ["Smith, W", "Jones, J", "Smith, J"]
    @ds.person.terms_of_address.should == ["Dr", "Mr", "Prof"]
    @ds.person.email.should == ["will.smith@example.com", "jack.jones@example.com"]
    @ds.person.institution.should == ["University of Oxford", "St Andrews University"]
    @ds.person.faculty.should == ["Humanities Division - English Language and Literature", "English Department"]
    @ds.person.oxford_college.should == ["Linacre College"]
    @ds.person.roleterm.text.should == ["author", "author", "Supervisor"]
    @ds.person.funder.should == ["Leverhulme Trust", "National Trust"]
    @ds.person.grant_number.should == ["Grant number for author funding", "Grant number for 2nd author funding"]
    @ds.person.website.should == ["http://example.com/author1", "http://example.com/author2"]
    @ds.person.uuid.should == ["uuid:1bcbd111-1477-412c-960e-453ce7f97dc5", "uuid:2bcbd222-2588-523d-960e-453ce7f97dc5"]
    @ds.person.webauth.should == ["abcd1234", "abcd5678"]

    @ds.person(0).first_name.should == ["Will"]
    @ds.person(0).last_name.should == ["Smith"]
    @ds.person(0).display_name.should == ["Smith, W"]
    @ds.person(0).terms_of_address.should == ["Dr"]
    @ds.person(0).email.should == ["will.smith@example.com"]
    @ds.person(0).institution.should == ["University of Oxford"]
    @ds.person(0).faculty.should == ["Humanities Division - English Language and Literature"]
    @ds.person(0).oxford_college.should == ["Linacre College"]
    @ds.person(0).research_group.should == ["Name of research group"]
    @ds.person(0).roleterm.text.should == ["author"]
    @ds.person(0).funder.should == ["Leverhulme Trust"]
    @ds.person(0).grant_number.should == ["Grant number for author funding"]
    @ds.person(0).website.should == ["http://example.com/author1"]
    @ds.person(0).uuid.should == ["uuid:1bcbd111-1477-412c-960e-453ce7f97dc5"]
    @ds.person(0).webauth.should == ["abcd1234"]

    @ds.person(1).first_name.should == ["Jack"]
    @ds.person(1).last_name.should == ["Jones"]
    @ds.person(1).display_name.should == ["Jones, J"]
    @ds.person(1).terms_of_address.should == ["Mr"]
    @ds.person(1).email.should == ["jack.jones@example.com"]
    @ds.person(1).institution.should == ["St Andrews University"]
    @ds.person(1).faculty.should == ["English Department"]
    @ds.person(1).oxford_college.should == []
    @ds.person(1).research_group.should == ["Name of 2nd research group"]
    @ds.person(1).roleterm.text.should == ["author"]
    @ds.person(1).funder.should == ["National Trust"]
    @ds.person(1).grant_number.should == ["Grant number for 2nd author funding"]
    @ds.person(1).website.should == ["http://example.com/author2"]
    @ds.person(1).uuid.should == ["uuid:2bcbd222-2588-523d-960e-453ce7f97dc5"]
    @ds.person(1).webauth.should == ["abcd5678"]

    @ds.person(2).first_name.should == ["Jada"]
    @ds.person(2).last_name.should == ["Smith"]
    @ds.person(2).display_name.should == ["Smith, J"]
    @ds.person(2).terms_of_address.should == ["Prof"]
    @ds.person(2).roleterm.text.should == ["Supervisor"]
    @ds.person(2).funder.should == []

    @ds.organisation.display_name.should == ["Name of Publisher"]
    @ds.organisation.roleterm.text.should == ["Publisher"]
    @ds.organisation.website.should == ["http://www.example.org/"]
    @ds.organisation.email.should == []

    @ds.organisation(0).display_name.should == ["Name of Publisher"]
    @ds.organisation(0).roleterm.text.should == ["Publisher"]
    @ds.organisation(0).website.should == ["http://www.example.org/"]

    #TODO: Define copyright holder correctly
    #@ds.copyright_holder.display_name.should == ["Will Smith"]
    #@ds.copyright_holder.roleterm.text.should == ["Copyright Holder"]
    #@ds.copyright_holder.rights_ownership.should == ["Sole authorship"]
    #@ds.copyright_holder.third_party_copyright.should == ["Contains Third Party copyright"]
    #@ds.copyright_holder.type.should == []

  end
end
