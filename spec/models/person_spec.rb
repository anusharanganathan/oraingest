require "spec_helper"

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
    @ds1.first_name.should == ["John"]
    @ds1.last_name.should == ["Tolkein"]
    @ds1.display_name.should == ["J. R. R. Tolkein"]
    @ds1.title.should == ["Prof."]
    @ds1.email.should == ["tolkein@example.com"]
    @ds1.website.should == ["http://en.wikipedia.org/wiki/J._R._R._Tolkien"]
    @ds1.webauth.should == ["mer123"]
    @ds1.institution.should == ["University of Oxford"]
    @ds1.faculty.should == ["Department of english language and literature"]
    @ds1.oxford_college.should == ["Pembroke College", "Merton College", "Exeter College"]
    @ds1.research_group.should == ['Inklings']

    @ds2.first_name.should == ["Mark"]
    @ds2.last_name.should == ["Twain"]
    @ds2.display_name.should == []
    @ds2.email.should == ["mark.twain@example.com"]
    @ds2.webauth.should == ["bod123"]
    @ds2.institution.should == ["University of Oxford"]
    @ds2.faculty.should == []
    @ds2.oxford_college.should == []
    @ds2.research_group.should == []

    @ds3.first_name.should == ["Salvatore"]
    @ds3.last_name.should == []
    @ds3.display_name.should == []
    @ds3.email.should == ["salvatore.dali@example.com"]
    @ds3.webauth.should == ["oxf456"]
    @ds3.institution.should == ["University of Oxford"]

    @ds4.first_name.should == []
    @ds4.last_name.should == ["Einstein"]
    @ds4.display_name.should == []
    @ds4.email.should == ["albert.einstein@example.com"]
    @ds4.webauth.should == ["oxf789"]
    @ds4.institution.should == ["University of Oxford"]

    @ds5.first_name.should == []
    @ds5.last_name.should == []
    @ds5.display_name.should == []
    @ds5.email.should == ["anonymous@example.com"]
    @ds5.webauth.should == ["oxf000"]
    @ds5.institution.should == ["University of Oxford"]
  end

  it "should allow you to ask for name" do
    @ds1.name.should == ["J. R. R. Tolkein"]
    @ds2.name.should == ["Mark Twain"]
    @ds3.name.should == ["Salvatore"]
    @ds4.name.should == ["Einstein"]
    @ds5.name.should == ["oxf000"]
  end
end
