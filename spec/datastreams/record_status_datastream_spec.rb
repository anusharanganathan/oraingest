require 'spec_helper'
#require 'pp'
describe Datastream::RecordStatusDatastream do
  before(:each) do
    @status = fixture("record_status_sample.xml")
    @ds = Datastream::RecordStatusDatastream.from_xml(@status)
  end
  it "should expose record status info with explicit terms and simple proxies" do
    #print the metadata
    #pp @ds.fields

    # modified date
    @ds.date_modified.should == ["2013-06-23T17:00:06Z"]
    # record date, status, reviewer name, reviewer id and note
    @ds.record.date.should == ["2013-06-15T15:41:56Z", "2013-06-18T15:41:56Z", "2013-06-20T15:41:56Z", "2013-06-20T15:44:56Z", "2013-06-21T15:44:56Z", "2013-06-22T15:44:56Z", "2013-06-23T15:44:56Z", "2013-06-23T17:00:06Z"]
    @ds.record.status.should == ["Draft", "Draft", "Submitted", "In Review", "Escalated", "Referred", "Approved", "Completed"]
    @ds.record.reviewer.name.should == ["Anusha", "Anne", "Anusha", "Anne"]
    @ds.record.reviewer.webauth.should == ["bodl0000", "bodl0001", "bodl0000", "bodl0001"]
    @ds.record.note.should == ["This is assigned to Anne for review", "Copyright clarification needed for x", "Author clarification needed for x", "This is ready to be published", "Record migrated, indexed and citation text created"]

    # testing proxies
    #TODO: Proxy definition within loops not working
    #@ds.record.reviewer_name.should == ["Anusha", "Anne", "Anusha", "Anne"]
    #@ds.record.reviewer_id.should == ["bodl0000", "bodl0001", "bodl0000", "bodl0001"]

    # Access each record individually
    @ds.record(0).date.should == ["2013-06-15T15:41:56Z"]
    @ds.record(0).status.should == ["Draft"]
    @ds.record(0).reviewer.name.should == []
    @ds.record(0).reviewer.webauth.should == []
    @ds.record(0).note.should == []

    @ds.record(1).date.should == ["2013-06-18T15:41:56Z"]
    @ds.record(1).status.should == ["Draft"]
    @ds.record(1).reviewer.name.should == []
    @ds.record(1).reviewer.webauth.should == []
    @ds.record(1).note.should == []
 
    @ds.record(2).date.should == ["2013-06-20T15:41:56Z"]
    @ds.record(2).status.should == ["Submitted"]
    @ds.record(2).reviewer.name.should == []
    @ds.record(2).reviewer.webauth.should == []
    @ds.record(2).note.should == []
 
    @ds.record(3).date.should == ["2013-06-20T15:44:56Z"]
    @ds.record(3).status.should == ["In Review"]
    @ds.record(3).reviewer.name.should == ["Anusha"]
    @ds.record(3).reviewer.webauth.should == ["bodl0000"]
    @ds.record(3).note.should == ["This is assigned to Anne for review"]
 
    @ds.record(4).date.should == ["2013-06-21T15:44:56Z"]
    @ds.record(4).status.should == ["Escalated"]
    @ds.record(4).reviewer.name.should == ["Anne"]
    @ds.record(4).reviewer.webauth.should == ["bodl0001"]
    @ds.record(4).note.should == ["Copyright clarification needed for x"]
 
    @ds.record(5).date.should == ["2013-06-22T15:44:56Z"]
    @ds.record(5).status.should == ["Referred"]
    @ds.record(5).reviewer.name.should == ["Anusha"]
    @ds.record(5).reviewer.webauth.should == ["bodl0000"]
    @ds.record(5).note.should == ["Author clarification needed for x"]
 
    @ds.record(6).date.should == ["2013-06-23T15:44:56Z"]
    @ds.record(6).status.should == ["Approved"]
    @ds.record(6).reviewer.name.should == ["Anne"]
    @ds.record(6).reviewer.webauth.should == ["bodl0001"]
    @ds.record(6).note.should == ["This is ready to be published"]
 
    @ds.record(7).date.should == ["2013-06-23T17:00:06Z"]
    @ds.record(7).status.should == ["Completed"]
    @ds.record(7).reviewer.name.should == []
    @ds.record(7).reviewer.webauth.should == []
    @ds.record(7).note.should == ["Record migrated, indexed and citation text created"]
  end
end
