require "spec_helper"

describe GenericFileRdfDatastream do
  before do
    @generic_file = GenericFile.new
    @generic_file.apply_depositor_metadata('anusha')
    @dsg = @generic_file.descMetadata
    @dsg.attributes = {title:"test", subtitle:"subtitle", abstract:"Abstract for paper"}

    @person1 = Person.new
    @dsp1 = @person1.descMetadata
    @dsp1.attributes = {first_name:"Mark",
      last_name:"Twain",
      display_name:"Twain, M",
      email:"mark.twain@example.com",
      webauth:"bod123",
      institution:"University of Oxford"}
    @person1.save
    
    @person2 = Person.new
    @dsp2 = @person2.descMetadata
    @dsp2.attributes = {first_name:"James",
      last_name:"Thurber",
      display_name:"Thurber, J",
      email:"james.thurber@example.com",
      webauth:"bod456",
      institution:"University of Oxford"}
    @person2.save

    @person3 = Person.new
    @dsp3 = @person3.descMetadata
    @dsp3.attributes = {first_name:"Charles",
      last_name:"Dickens",
      display_name:"Dickens, C",
      email:"charles.dickens@example.com",
      webauth:"bod789",
      institution:"Penguin Publishers"}
    @person3.save

    @generic_file.authors = [@person1, @person2]
    #@generic_file.authors = [@person1]
    @generic_file.copyright_holders = [@person3]
    @generic_file.save
    #Has many associations writes to rels-ext of person
    @person1.save
    @person2.save
    @person3.save
  end

  it "should allow you to express values" do
    @dsg.title.should == ["test"]
    @dsg.subtitle.should == ["subtitle"]
    @dsg.abstract.should == ["Abstract for paper"]
  end

  it "shoud allow you to associate files with people" do
    @generic_file.authors.count == 2
    @generic_file.copyright_holders.count == 1

    puts @generic_file.authors.first
    puts @generic_file.datastreams["RELS-EXT"].to_rels_ext
  end

  it "should allow you to get people attaributes" do
    pending "Is this possible?"
    @generic_file.authors.first.first_name.should == ["Mark"]
    @generic_file.authors.first.last_name.should == ["Twain"]
    @generic_file.authors.first.display_name.should == ["Twain, M"]
    @generic_file.authors.first.email.should == ["mark.twain@example.com"]
    @generic_file.authors.first.webauth.should == ["bod123"]
    @generic_file.authors.first.institution.should == ["University of Oxford"]
    @generic_file.authors.first.name.should == ["Twain, M"]

    @generic_file.authors.last.first_name.should == ["James"]
    @generic_file.authors.last.last_name.should == ["Thurber"]
    @generic_file.authors.last.display_name.should == ["Thurber, J"]
    @generic_file.authors.last.email.should == ["james.thurber@example.com"]
    @generic_file.authors.last.webauth.should == ["bod456"]
    @generic_file.authors.last.institution.should == ["University of Oxford"]
    @generic_file.authors.last.name.should == ["Thurber, J"]

    @generic_file.copyright_holders.first.first_name.should == ["Charles"]
    @generic_file.copyright_holders.first.last_name.should == ["Dickens"]
    @generic_file.copyright_holders.first.display_name.should == ["Dickens, C"]
    @generic_file.copyright_holders.first.email.should == ["charles.dickens@example.com"]
    @generic_file.copyright_holders.first.webauth.should == ["bod789"]
    @generic_file.copyright_holders.first.institution.should == ["Penguin Publishers"]
    @generic_file.copyright_holders.first.name.should == ["Dickens, C"]
  end
end
