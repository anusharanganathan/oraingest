require "rails_helper"

describe Person do
  before do
    @person1 = Person.new
    @ds1 = @person1.descMetadata
    @ds1.attributes = {first_name:"John", 
      last_name:"Tolkein", 
      display_name:"J. R. R. Tolkein", 
      title:"Prof.",
      email:"tolkein@example.com", 
      website:"http://en.wikipedia.org/wiki/J._R._R._Tolkien",
      webauth:"mer123", 
      institution:"University of Oxford",
      faculty:"Department of english language and literature",
      oxford_college:["Pembroke College", "Merton College", "Exeter College"],
      research_group:"Inklings"
      }

    @person2 = Person.new
    @ds2 = @person2.descMetadata
    @ds2.attributes = {first_name:"Mark", 
      last_name:"Twain", 
      email:"mark.twain@example.com", 
      webauth:"bod123", 
      institution:"University of Oxford"
    }
      
    @person3 = Person.new
    @ds3 = @person3.descMetadata
    @ds3.attributes = {first_name:"Salvatore", 
      email:"salvatore.dali@example.com", 
      webauth:"oxf456", 
      institution:"University of Oxford"
    }
      
    @person4 = Person.new
    @ds4 = @person4.descMetadata
    @ds4.attributes = {last_name:"Einstein", 
      email:"albert.einstein@example.com", 
      webauth:"oxf789", 
      institution:"University of Oxford"
    }
      
    @person5 = Person.new
    @ds5 = @person5.descMetadata
    @ds5.attributes = {email:"anonymous@example.com", 
      webauth:"oxf000", 
      institution:"University of Oxford"
    }
      
  end

  it "should allow you to express values" do
    expect(@ds1.first_name).to eq(["John"])
    expect(@ds1.last_name).to eq(["Tolkein"])
    expect(@ds1.display_name).to eq(["J. R. R. Tolkein"])
    expect(@ds1.title).to eq(["Prof."])
    expect(@ds1.email).to eq(["tolkein@example.com"])
    expect(@ds1.website).to eq(["http://en.wikipedia.org/wiki/J._R._R._Tolkien"])
    expect(@ds1.webauth).to eq(["mer123"])
    expect(@ds1.institution).to eq(["University of Oxford"])
    expect(@ds1.faculty).to eq(["Department of english language and literature"])
    expect(@ds1.oxford_college).to eq(["Pembroke College", "Merton College", "Exeter College"])
    expect(@ds1.research_group).to eq(['Inklings'])

    expect(@ds2.first_name).to eq(["Mark"])
    expect(@ds2.last_name).to eq(["Twain"])
    expect(@ds2.display_name).to eq([])
    expect(@ds2.email).to eq(["mark.twain@example.com"])
    expect(@ds2.webauth).to eq(["bod123"])
    expect(@ds2.institution).to eq(["University of Oxford"])
    expect(@ds2.faculty).to eq([])
    expect(@ds2.oxford_college).to eq([])
    expect(@ds2.research_group).to eq([])

    expect(@ds3.first_name).to eq(["Salvatore"])
    expect(@ds3.last_name).to eq([])
    expect(@ds3.display_name).to eq([])
    expect(@ds3.email).to eq(["salvatore.dali@example.com"])
    expect(@ds3.webauth).to eq(["oxf456"])
    expect(@ds3.institution).to eq(["University of Oxford"])

    expect(@ds4.first_name).to eq([])
    expect(@ds4.last_name).to eq(["Einstein"])
    expect(@ds4.display_name).to eq([])
    expect(@ds4.email).to eq(["albert.einstein@example.com"])
    expect(@ds4.webauth).to eq(["oxf789"])
    expect(@ds4.institution).to eq(["University of Oxford"])

    expect(@ds5.first_name).to eq([])
    expect(@ds5.last_name).to eq([])
    expect(@ds5.display_name).to eq([])
    expect(@ds5.email).to eq(["anonymous@example.com"])
    expect(@ds5.webauth).to eq(["oxf000"])
    expect(@ds5.institution).to eq(["University of Oxford"])
  end

  it "should allow you to ask for name" do
    expect(@ds1.name).to eq(["J. R. R. Tolkein"])
    expect(@ds2.name).to eq(["Mark Twain"])
    expect(@ds3.name).to eq(["Salvatore"])
    expect(@ds4.name).to eq(["Einstein"])
    expect(@ds5.name).to eq(["oxf000"])
  end
end
