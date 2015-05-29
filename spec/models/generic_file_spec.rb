require "rails_helper"

describe GenericFile do
  before do
    @generic_file = GenericFile.new
  end
  subject {@generic_file}

  describe 'attributes' do
    it { is_expected.to respond_to(:permissions) }
    it { is_expected.to respond_to(:workflows) }

    context 'GenericFileRdfDatastream' do
      it { is_expected.to respond_to(:part_of) }
      it { is_expected.to respond_to(:resource_type,) }
      it { is_expected.to respond_to(:title) }
      it { is_expected.to respond_to(:subtitle) }
      it { is_expected.to respond_to(:creator) }
      it { is_expected.to respond_to(:rights_ownership) }
      it { is_expected.to respond_to(:third_party_copyright) }
      it { is_expected.to respond_to(:description) }
      it { is_expected.to respond_to(:abstract) }
      it { is_expected.to respond_to(:subject) }
      it { is_expected.to respond_to(:keyword) }
      it { is_expected.to respond_to(:language) }
      it { is_expected.to respond_to(:doi) }
      it { is_expected.to respond_to(:local_id) }
      it { is_expected.to respond_to(:issn) }
      it { is_expected.to respond_to(:isbn) }
      it { is_expected.to respond_to(:eissn) }
      it { is_expected.to respond_to(:uuid) }
      it { is_expected.to respond_to(:identifier) }
      it { is_expected.to respond_to(:grant_number) }
      it { is_expected.to respond_to(:edition) }
      it { is_expected.to respond_to(:status) }
      it { is_expected.to respond_to(:version) }
      it { is_expected.to respond_to(:journal) }
      it { is_expected.to respond_to(:volume) }
      it { is_expected.to respond_to(:issue) }
      it { is_expected.to respond_to(:pages) }
      it { is_expected.to respond_to(:tag) }
      it { is_expected.to respond_to(:rights) }
      it { is_expected.to respond_to(:date_created) }
      it { is_expected.to respond_to(:date_uploaded) }
      it { is_expected.to respond_to(:date_modified) }
      it { is_expected.to respond_to(:based_near) }
      it { is_expected.to respond_to(:related_url) }
    end
  end

  describe 'workflows' do
    after do
      subject.delete if subject.persisted?
    end

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
  end

  describe "create" do
    context 'when not already there' do
      before(:each) do
        Timecop.freeze
        @generic_file.apply_depositor_metadata("fake@example.com")
        @generic_file.save
      end
      after(:each) do
        @generic_file.delete
        Timecop.return
      end

      it "should initialize submission workflow" do
        expect(@generic_file.workflows.count).to eq(1)
        wf = @generic_file.workflows.first
        expect(wf.identifier).to eq(["MediatedSubmission"])
        expect(wf.current_status).to eq("Draft")
        expect(wf.entries.first.date.first).to include(Time.new.strftime("%Y-%m-%d %H:%M"))
      end

    end

    context 'when already there' do
      before do
        @in_review = GenericFile.new(title: "Item In Review", workflows_attributes:
                                                                [{identifier: "MediatedSubmission", entries_attributes: [{status: "Assigned", reviewer_id: "fake@example.com"}]}] )
        @in_review.apply_depositor_metadata("fake@example.com")
      end
      after do
        @in_review.delete
      end
      it "should skip initializing workflow" do
        expect(@in_review.workflows.count).to eq(1)
        @in_review.save
        expect(@in_review.workflows.count).to eq(1)
        expect(@in_review.workflows.first.current_status).to eq("Assigned")
      end
    end
  end
end