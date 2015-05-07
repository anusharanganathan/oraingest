require "rails_helper"
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
    expect(wf1.entries.count).to eq(4)
    expect(wf1.entries.first.status).to eq(["Submitted"])
    expect(wf1.entries.first.date).to eq([HOUR_AGO])
    expect(wf1.entries.last.status).to eq(["Approved"])
    expect(wf1.entries.last.date).to eq([QUARTER_HOUR_AGO])
    expect(wf1.entries.last.creator).to eq([@user.user_key])
    expect(wf1.comments.count).to eq(2)
    expect(wf1.comments.first.description).to eq(["This is over my head\n I can't review it."])
    expect(wf1.comments.first.creator).to eq(["user23"])
    expect(wf1.comments.last.description).to eq(["Looks fine to me."])
    expect(wf1.comments.last.creator).to eq([@user.user_key])
    
    wf2 = subject.workflows[1]
    expect(wf2.entries.count).to eq(2)
    expect(wf2.comments.count).to eq(0)
  end
  describe "Workflow#current_status" do
    it "should return the status from the _last_ entry of the workflow" do
      expect(subject.workflows.first.current_status).to eq("Approved")
    end
  end
  describe "Datastream#current_statuses" do
    it "should return the status from the _last_ entry of each workflow" do
      expect(subject.current_statuses).to eq(["Approved", "Success"])
    end
  end
  describe "WorkflowEntry#reviewer" do
    it "should return a User object based on the reviewer_id Entry" do
      expect(subject.workflows.first.entries.first.reviewer).to be_nil
      expect(subject.workflows.first.entries.last.reviewer).to eq(@user)
    end
  end
  describe "Workflow#current_reviewer" do
    it "should return a User object based on the reviewer_id on the last entry of the workflow" do
      expect(subject.workflows.first.current_reviewer).to eq(@user)
    end
  end
  describe "Workflow#submission_entry" do
    it "should return a User object based on the reviewer_id on the last entry of the workflow" do
      expect(subject.workflows.first.submission_entry).to eq(@submission_entry)
    end
  end
  describe "Workflow#date_submitted" do
    it "should return a User object based on the reviewer_id on the last entry of the workflow" do
      expect(subject.workflows.first.date_submitted).to eq(HOUR_AGO)
    end
  end
  it "should solrize" do
    solr_doc = subject.to_solr
    expect(solr_doc[Solrizer.solr_name("all_workflow_statuses", :symbol)]).to eq(["Approved", "Success"])
    expect(solr_doc[Solrizer.solr_name("MediatedSubmission_status", :symbol)]).to eq("Approved")
    expect(solr_doc[Solrizer.solr_name("MediatedSubmission_current_reviewer_id", :symbol)]).to eq(@user.user_key)
    expect(solr_doc[Solrizer.solr_name("MediatedSubmission_all_reviewer_ids", :symbol)]).to eq(['foouser', 'user23', @user.user_key])
    expect(solr_doc[Solrizer.solr_name("MediatedSubmission_date_submitted", :dateable)]).to eq(Time.parse(HOUR_AGO).utc.iso8601)
    expect(solr_doc[Solrizer.solr_name("VirusCheck_status", :symbol)]).to eq("Success")
  end
  it "should skip invalid dates when solrizing" do
    @datstream.workflows = []
    wf1 = @datstream.workflows.build(identifier:"MediatedSubmission")
    wf1.entries.build(status:"Submitted", reviewer_id: nil, date:"1nvalid3 DATE")
    solr_doc = @datstream.to_solr
    expect(solr_doc[Solrizer.solr_name("MediatedSubmission_date_submitted", :dateable)]).to be_nil
  end
end