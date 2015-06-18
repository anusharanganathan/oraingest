require 'rails_helper'

describe Dataset do
  it_behaves_like 'doi_methods'

  describe 'attributes' do

    before do
      @dataset = Dataset.new
    end

    subject { @dataset }

    it { is_expected.to respond_to(:permissions) }
    # it { is_expected.to respond_to(:permissions_attributes) }
    it { is_expected.to respond_to(:workflows) }
    # it { is_expected.to respond_to(:workflows_attributes) }
    context 'DatasetRdfDatastream' do
      it { is_expected.to respond_to(:title) }
      it { is_expected.to respond_to(:subtitle) }
      it { is_expected.to respond_to(:abstract) }
      it { is_expected.to respond_to(:subject) }
      it { is_expected.to respond_to(:keyword) }
      it { is_expected.to respond_to(:worktype) }
      it { is_expected.to respond_to(:language) }
      it { is_expected.to respond_to(:license) }
      it { is_expected.to respond_to(:dateCopyrighted) }
      it { is_expected.to respond_to(:rightsHolder) }
      it { is_expected.to respond_to(:rights) }
      it { is_expected.to respond_to(:rightsActivity) }
      it { is_expected.to respond_to(:creation) }
      it { is_expected.to respond_to(:funding) }
      it { is_expected.to respond_to(:publication) }
    end

    context 'RelationsRdfDatastream' do
      it { is_expected.to respond_to(:hasPart) }
      it { is_expected.to respond_to(:accessRights) }
      it { is_expected.to respond_to(:influence) }
      it { is_expected.to respond_to(:qualifiedRelation) }
    end

    context 'DatasetAdminRdfDatastream' do
      it { is_expected.to respond_to(:hasAgreement) }
      it { is_expected.to respond_to(:storageAgreement) }
      it { is_expected.to respond_to(:note) }
      it { is_expected.to respond_to(:adminLocator) }
      it { is_expected.to respond_to(:adminDigitalSize) }
    end

  end

  describe 'when creating a new dataset' do
    before do
      @dataset = Dataset.new
    end

    after do
      @dataset.delete
    end

    it 'initializes the submission workflow' do
      @dataset.save
      expect(@dataset.workflows).not_to be_empty
      wf = @dataset.workflows.select{|wf| wf.identifier.first =="MediatedSubmission"}.first
      expect(wf.current_status).to eq ("Draft")
    end

    it 'removes blank assertions' do
      @dataset.title = 'Test title'
      @dataset.subtitle = ''
      @dataset.save
      expect(@dataset.title).to eq(['Test title'])
      expect(@dataset.subtitle).to eq([])
      expect(@dataset.keyword).to eq([])
    end
  end

  describe 'applying permissions' do
    before do
      @dataset = Dataset.new
      @reviewer = FactoryGirl.find_or_create(:reviewer)
      @dataset.apply_permissions(@reviewer)
    end

    it 'should set the permisions' do
      expect(@dataset.permissions).not_to be_empty
    end

    it 'sets the permissions to reviewer/group/edit' do
      permission = @dataset.permissions.first
      expect(permission.name).to eq('reviewer')
      expect(permission.type).to eq('group')
      expect(permission.access).to eq('edit')
    end
  end

  describe '#to_jq_upload' do
    before do
      @dataset = Dataset.new
      @jq_upload = @dataset.to_jq_upload('title', 120, 'uuid:nn999n999', 'dsid')
    end

    it 'creates the jq upload params' do
      expect(@jq_upload).to be_a(Hash)
    end

    it 'sets the name' do
      expect(@jq_upload['name']).to eq('title')
    end

    it 'sets the size' do
      expect(@jq_upload['size']).to eq(120)
    end

    it 'sets the url' do
      expect(@jq_upload['url']).to eq('/datasets/uuid:nn999n999/file/dsid')
    end

    it 'sets the thumbnail url' do
      expect(@jq_upload['thumbnail_url']).to eq('fileIcons/default-icon-48x48.png')
    end

    it 'sets the delete url' do
      expect(@jq_upload['delete_url']).to eq('/datasets/uuid:nn999n999/file/dsid')
    end

    it 'sets the delete type' do
      expect(@jq_upload['delete_type']).to eq('DELETE')
    end

  end

  describe 'mint datastream id' do
    before do
      @dataset = Dataset.new
      @dsid = @dataset.mint_datastream_id
    end

    it 'creates the datastream identifier' do
      expect(@dsid).not_to be_empty
      expect(@dsid).to be_a(String)
    end

  end

  describe 'get the class name' do
    before do
      @dataset = Dataset.new
    end

    it 'returns the class name' do
      expect(@dataset.model_klass).to eq('Dataset')
    end

  end

end
