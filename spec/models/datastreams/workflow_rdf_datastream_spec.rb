require "spec_helper"
HOUR_AGO = (Time.now-3600).utc.iso8601
HALF_HOUR_AGO = (Time.now-1800).utc.iso8601
UNDER_HALF_HOUR_AGO = (Time.now-1700).utc.iso8601
QUARTER_HOUR_AGO = (Time.now-900).utc.iso8601

describe WorkflowRdfDatastream do
  before do
    @user = FactoryGirl.find_or_create(:user)
    @generic_file = GenericFile.new
    @datstream = @generic_file.workflowMetadata
    
    wf1 = @datstream.workflows.build(identifier:"MediatedSubmission")
    wf2 =  @datstream.workflows.build(identifier:"VirusCheck")
    @submission_entry = wf1.entries.build(status:"Submitted", reviewer_id: nil, date:HOUR_AGO)
    wf1.entries.build(status:"Assigned", reviewer_id: "user23", date:HALF_HOUR_AGO, creator:"foouser")
    wf1.comments.build(creator:"user23", date:UNDER_HALF_HOUR_AGO, description:"This is over my head\n I can't review it.")
    wf1.entries.build(status:"Escalated", reviewer_id: @user.user_key, date:UNDER_HALF_HOUR_AGO, creator:"user23")
    wf1.comments.build(creator:@user.user_key, date:QUARTER_HOUR_AGO, description:"Looks fine to me.")
    wf1.entries.build(status:"Approved", reviewer_id: @user.user_key, date:QUARTER_HOUR_AGO, creator:@user.user_key)
    
    wf2.entries.build(status:"Submitted", reviewer_id: nil, date:HOUR_AGO)
    wf2.entries.build(status:"Success", reviewer_id: nil, date:HOUR_AGO)
  end
  subject { @datstream }
  it "should allow you to express multiple workflows with multiple entries and comments" do
    # puts subject.content
    wf1 = subject.workflows.first
    wf1.entries.count.should == 4
    wf1.entries.first.status.should == ["Submitted"]
    wf1.entries.first.date.should == [HOUR_AGO]
    wf1.entries.last.status.should == ["Approved"]
    wf1.entries.last.date.should == [QUARTER_HOUR_AGO]
    wf1.entries.last.creator.should == [@user.user_key]
    wf1.comments.count.should == 2
    wf1.comments.first.description.should == ["This is over my head\n I can't review it."]
    wf1.comments.first.creator.should == ["user23"]
    wf1.comments.last.description.should == ["Looks fine to me."]
    wf1.comments.last.creator.should == [@user.user_key]
    
    wf2 = subject.workflows[1]
    wf2.entries.count.should == 2
    wf2.comments.count.should == 0
  end
  describe "Workflow#current_status" do
    it "should return the status from the _last_ entry of the workflow" do
      subject.workflows.first.current_status.should == "Approved"
    end
  end
  describe "Datastream#current_statuses" do
    it "should return the status from the _last_ entry of each workflow" do
      subject.current_statuses.should == ["Approved", "Success"]
    end
  end
  describe "WorkflowEntry#reviewer" do
    it "should return a User object based on the reviewer_id Entry" do
      subject.workflows.first.entries.first.reviewer.should be_nil
      subject.workflows.first.entries.last.reviewer.should == @user
    end
  end
  describe "Workflow#current_reviewer" do
    it "should return a User object based on the reviewer_id on the last entry of the workflow" do
      subject.workflows.first.current_reviewer.should == @user
    end
  end
  describe "Workflow#submission_entry" do
    it "should return a User object based on the reviewer_id on the last entry of the workflow" do
      subject.workflows.first.submission_entry.should == @submission_entry
    end
  end
  describe "Workflow#date_submitted" do
    it "should return a User object based on the reviewer_id on the last entry of the workflow" do
      subject.workflows.first.date_submitted.should == HOUR_AGO
    end
  end
  it "should solrize" do
    solr_doc = subject.to_solr
    solr_doc[Solrizer.solr_name("all_workflow_statuses", :symbol)].should == ["Approved", "Success"]
    solr_doc[Solrizer.solr_name("MediatedSubmission_status", :symbol)].should == "Approved"
    solr_doc[Solrizer.solr_name("MediatedSubmission_current_reviewer_id", :symbol)].should == @user.user_key
    solr_doc[Solrizer.solr_name("MediatedSubmission_all_reviewer_ids", :symbol)].should == ['foouser', 'user23', @user.user_key]
    solr_doc[Solrizer.solr_name("MediatedSubmission_date_submitted", :dateable)].should == Time.parse(HOUR_AGO).utc.iso8601
    solr_doc[Solrizer.solr_name("VirusCheck_status", :symbol)].should == "Success"
  end
  it "should skip invalid dates when solrizing" do
    @datstream.workflows = []
    wf1 = @datstream.workflows.build(identifier:"MediatedSubmission")
    wf1.entries.build(status:"Submitted", reviewer_id: nil, date:"1nvalid3 DATE")
    solr_doc = @datstream.to_solr
    solr_doc[Solrizer.solr_name("MediatedSubmission_date_submitted", :dateable)].should be_nil
  end
end