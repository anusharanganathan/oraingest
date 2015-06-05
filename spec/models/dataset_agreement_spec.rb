require "rails_helper"

describe DatasetAgreement do

  describe 'attributes' do

    before do
      @agreement = DatasetAgreement.new
    end

    subject { @agreement }

    it { is_expected.to respond_to(:permissions) }

    context 'DatasetAgreementRdfDatastream' do
      it { is_expected.to respond_to(:identifier) }
      it { is_expected.to respond_to(:title) }
      it { is_expected.to respond_to(:agreementType) }
      it { is_expected.to respond_to(:annotation) }
      it { is_expected.to respond_to(:digitalSizeAllocated) }
      it { is_expected.to respond_to(:dataStorageSilo) }
      it { is_expected.to respond_to(:status) }
      it { is_expected.to respond_to(:contributor) }
      it { is_expected.to respond_to(:references) }
      it { is_expected.to respond_to(:valid) }
      it { is_expected.to respond_to(:creation) }
      it { is_expected.to respond_to(:titularActivity) }
      it { is_expected.to respond_to(:invoice) }
      it { is_expected.to respond_to(:funding) }
    end

    context 'RelationsRdfDatastream' do
      it { is_expected.to respond_to(:hasPart) }
      it { is_expected.to respond_to(:accessRights) }
      it { is_expected.to respond_to(:influence) }
      it { is_expected.to respond_to(:qualifiedRelation) }
    end
  end


  describe 'when creating a new dataset agreement' do
    before do
      @agreement = DatasetAgreement.new
    end

    after do
      @agreement.delete
    end

    it 'removes blank assertions' do
      @agreement.title = 'Test title'
      @agreement.annotation = ''
      @agreement.save
      expect(@agreement.title).to eq(['Test title'])
      expect(@agreement.annotation).to eq([])
      expect(@agreement.identifier).to eq([])
    end
  end

  describe 'applying permissions' do
    before do
      @agreement = DatasetAgreement.new
      @reviewer = FactoryGirl.find_or_create(:reviewer)
      @agreement.apply_permissions(@reviewer)
    end

    it 'should set the permisions' do
      expect(@agreement.permissions).not_to be_empty
      expect(@agreement.permissions.size).to eq(3)
    end

    it 'sets the permissions' do
      permission = @agreement.permissions[0]
      expect(permission.name).to eq('registered')
      expect(permission.type).to eq('group')
      expect(permission.access).to eq('read')
      permission = @agreement.permissions[1]
      expect(permission.name).to eq('reviewer')
      expect(permission.type).to eq('group')
      expect(permission.access).to eq('edit')
      permission = @agreement.permissions[2]
      expect(permission.name).to eq('archivist1@example.com')
      expect(permission.type).to eq('user')
      expect(permission.access).to eq('edit')
    end
  end

  describe '#to_jq_upload' do
    before do
      @agreement = DatasetAgreement.new
      @jq_upload = @agreement.to_jq_upload('title', 120, 'uuid:nn999n999', 'dsid')
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
      expect(@jq_upload['url']).to eq('/dataset_agreements/uuid:nn999n999/file/dsid')
    end

    it 'sets the thumbnail url' do
      expect(@jq_upload['thumbnail_url']).to eq('fileIcons/default-icon-48x48.png')
    end

    it 'sets the delete url' do
      expect(@jq_upload['delete_url']).to eq('/dataset_agreements/uuid:nn999n999/file/dsid')
    end

    it 'sets the delete type' do
      expect(@jq_upload['delete_type']).to eq('DELETE')
    end

  end

end