require "rails_helper"

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
    expect(subject.workflows.first.identifier).to eq(["MediatedSubmission"])
    expect(subject.workflows.first.entries.count).to eq(1)
    expect(subject.workflows.first.current_status).to eq("Submitted")
    expect(subject.workflows.first.current_reviewer).to be_nil
    
    expect(subject.workflows.last.identifier).to eq(["VirusCheck"])
    expect(subject.workflows.last.current_status).to eq("Queued")
    
    subject.update_attributes( workflows_attributes: [{
                                  id: subject.workflows.first.rdf_subject.to_s,
                                  entries_attributes: [{status: "Assigned", reviewer_id: "bob123"}],
                                  comments_attributes: [{creator: "bob123", description: "Some comment text"}]
                                  }] )
                              
    expect(subject.workflows.first.entries.count).to eq(2)
    expect(subject.workflows.first.entries.first.status).to eq(["Submitted"])
    expect(subject.workflows.first.entries.last.reviewer_id).to eq(["bob123"])
    expect(subject.workflows.first.entries.last.status).to eq(["Assigned"])
    expect(subject.workflows.first.current_status).to eq("Assigned")
    expect(subject.workflows.first.comments.first.creator).to eq(["bob123"])
    expect(subject.workflows.first.comments.first.description).to eq(["Some comment text"])
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
      expect(@generic_file.workflows.count).to eq(1)
      wf = @generic_file.workflows.first
      expect(wf.identifier).to eq(["MediatedSubmission"])
      expect(wf.current_status).to eq("Draft")
      expect(wf.entries.first.date.first).to include(Time.new.strftime("%Y-%m-%d %H:%M"))
    end
    it "should skip initializing workflow if it's already there" do
      @in_review = GenericFile.new(title: "Item In Review", workflows_attributes:
                            [{identifier: "MediatedSubmission", entries_attributes: [{status: "Assigned", reviewer_id: "fake@example.com"}]}] )
      @in_review.apply_depositor_metadata("fake@example.com")
      expect(@in_review.workflows.count).to eq(1)
      @in_review.save
      expect(@in_review.workflows.count).to eq(1)
      expect(@in_review.workflows.first.current_status).to eq("Assigned")
    end
  end
end