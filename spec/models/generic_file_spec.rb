require "spec_helper"

describe GenericFile do
  before do
    @generic_file = GenericFile.new
  end
  subject {@generic_file}
  it "should allow updating workflows" do
    subject.update_attributes( { workflows_attributes: [
                          {identifier: "MediatedSubmission", entries_attributes: [{status: "Submitted"}]},
                          {identifier: "VirusCheck", entries_attributes: [{status: "Queued"}]}
                          ]} )
    subject.workflows.first.identifier.should == ["MediatedSubmission"]
    subject.workflows.first.entries.count.should == 1
    subject.workflows.first.current_status.should == "Submitted"
    subject.workflows.first.current_reviewer.should be_nil
    
    subject.workflows.last.identifier.should == ["VirusCheck"]
    subject.workflows.last.current_status.should == "Queued"
    
    subject.update_attributes( workflows_attributes: [{
                                  id: subject.workflows.first.rdf_subject.to_s,
                                  entries_attributes: [{status: "Assigned", reviewer_id: "bob123"}],
                                  comments_attributes: [{creator: "bob123", description: "Some comment text"}]
                                  }] )
                              
    subject.workflows.first.entries.count.should == 2
    subject.workflows.first.entries.first.status.should == ["Submitted"]
    subject.workflows.first.entries.last.reviewer_id.should == ["bob123"]
    subject.workflows.first.entries.last.status.should == ["Assigned"]
    subject.workflows.first.current_status.should == "Assigned"
    subject.workflows.first.comments.first.creator.should == ["bob123"]
    subject.workflows.first.comments.first.description.should == ["Some comment text"]
  end
  describe "create" do
    before(:each) do
      @generic_file.apply_depositor_metadata("fake@example.com")
      @generic_file.save
    end
    after(:each) do
      @generic_file.delete
    end
    it "should initialize submission workflow" do
      @generic_file.workflows.count.should == 1
      wf = @generic_file.workflows.first
      wf.identifier.should == ["MediatedSubmission"]
      wf.current_status.should == "Draft"
      wf.entries.first.date.first.should include(Time.new.strftime("%Y-%m-%d %H:%M"))
    end
    it "should skip initializing workflow if it's already there" do
      @in_review = GenericFile.new(title: "Item In Review", workflows_attributes:
                            [{identifier: "MediatedSubmission", entries_attributes: [{status: "Assigned", reviewer_id: "fake@example.com"}]}] )
      @in_review.apply_depositor_metadata("fake@example.com")
      @in_review.workflows.count.should == 1
      @in_review.save
      @in_review.workflows.count.should == 1
      @in_review.workflows.first.current_status.should == "Assigned"
    end
  end
end