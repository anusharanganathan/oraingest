require "rails_helper"

describe ArticleRdfDatastream do
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
    expect(@dsg.title).to eq(["test"])
    expect(@dsg.subtitle).to eq(["subtitle"])
    expect(@dsg.abstract).to eq(["Abstract for paper"])
  end

  it "shoud allow you to associate files with people" do
    @generic_file.authors.count == 2
    @generic_file.copyright_holders.count == 1
    #puts @generic_file.authors.first
    #puts @generic_file.datastreams["RELS-EXT"].to_rels_ext
  end

  it "should allow you to get people attributes" do
    #pending "Is this possible?"
    expect(@generic_file.authors.first.first_name).to eq(["Mark"])
    expect(@generic_file.authors.first.last_name).to eq(["Twain"])
    expect(@generic_file.authors.first.display_name).to eq(["Twain, M"])
    expect(@generic_file.authors.first.email).to eq(["mark.twain@example.com"])
    expect(@generic_file.authors.first.webauth).to eq(["bod123"])
    expect(@generic_file.authors.first.institution).to eq(["University of Oxford"])
    expect(@generic_file.authors.first.name).to eq(["Twain, M"])

    expect(@generic_file.authors.last.first_name).to eq(["James"])
    expect(@generic_file.authors.last.last_name).to eq(["Thurber"])
    expect(@generic_file.authors.last.display_name).to eq(["Thurber, J"])
    expect(@generic_file.authors.last.email).to eq(["james.thurber@example.com"])
    expect(@generic_file.authors.last.webauth).to eq(["bod456"])
    expect(@generic_file.authors.last.institution).to eq(["University of Oxford"])
    expect(@generic_file.authors.last.name).to eq(["Thurber, J"])

    expect(@generic_file.copyright_holders.first.first_name).to eq(["Charles"])
    expect(@generic_file.copyright_holders.first.last_name).to eq(["Dickens"])
    expect(@generic_file.copyright_holders.first.display_name).to eq(["Dickens, C"])
    expect(@generic_file.copyright_holders.first.email).to eq(["charles.dickens@example.com"])
    expect(@generic_file.copyright_holders.first.webauth).to eq(["bod789"])
    expect(@generic_file.copyright_holders.first.institution).to eq(["Penguin Publishers"])
    expect(@generic_file.copyright_holders.first.name).to eq(["Dickens, C"])
  end
end
