require 'rails_helper'

describe Thesis do

  describe 'attributes' do

    before do
      @thesis = Thesis.new
    end

    subject { @thesis }

    it { is_expected.to respond_to(:permissions) }
    it { is_expected.to respond_to(:workflows) }

    context 'ThesisRdfDatastream' do
      it { is_expected.to respond_to(:title) }
    end
  end

  describe 'when creating a new thesis' do
    before do
      @thesis = Thesis.new
    end

    after do
      @thesis.delete
    end

    it 'initializes the submission workflow' do
      @thesis.save
      expect(@thesis.workflows.count).to eq(1)
      workflow = @thesis.workflows.first
      expect(workflow.identifier).to eq(["MediatedSubmission"])
      expect(workflow.current_status).to eq("Draft")
    end

    it 'removes blank assertions' do
      @thesis.title = 'Test title'
      @thesis.subtitle = ''
      @thesis.save
      expect(@thesis.title).to eq(['Test title'])
      expect(@thesis.subtitle).to eq([])
    end
  end

end