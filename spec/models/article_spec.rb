require 'rails_helper'

describe Article do

  it_behaves_like 'doi_methods'

  describe 'attributes' do

    before do
      @article = Article.new
    end

    subject { @article }

    it { is_expected.to respond_to(:permissions) }
    # it { is_expected.to respond_to(:permissions_attributes) }
    it { is_expected.to respond_to(:workflows) }
    # it { is_expected.to respond_to(:workflows_attributes) }

    context 'ArticleRdfDatastream' do
      it { is_expected.to respond_to(:title) }
      it { is_expected.to respond_to(:subtitle) }
      it { is_expected.to respond_to(:abstract) }
      it { is_expected.to respond_to(:subject) }
      it { is_expected.to respond_to(:keyword) }
      it { is_expected.to respond_to(:worktype) }
      it { is_expected.to respond_to(:medium) }
      it { is_expected.to respond_to(:language) }
      it { is_expected.to respond_to(:publicationStatus) }
      it { is_expected.to respond_to(:reviewStatus) }
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

    context 'ArticleAdminRdfDatastream' do
      it { is_expected.to respond_to(:oaStatus) }
      it { is_expected.to respond_to(:apcPaid) }
      it { is_expected.to respond_to(:oaReason) }
      it { is_expected.to respond_to(:refException) }
    end

  end

  describe 'when creating a new article' do
    before do
      @article = Article.new
    end

    after do
      @article.delete
    end

    it 'initializes the submission workflow' do
      @article.save
      expect(@article.workflows.count).to eq(1)
      workflow = @article.workflows.first
      expect(workflow.identifier).to eq(["MediatedSubmission"])
      expect(workflow.current_status).to eq("Draft")
    end

    it 'removes blank assertions' do
      @article.title = 'Test title'
      @article.subtitle = ''
      @article.save
      expect(@article.title).to eq(['Test title'])
      expect(@article.subtitle).to eq([])
      expect(@article.keyword).to eq([])
    end
  end

  describe 'applying permissions' do
    before do
      @article = Article.new
      @reviewer = FactoryGirl.find_or_create(:reviewer)
      @article.apply_permissions(@reviewer)
    end

    it 'should set the permisions' do
      expect(@article.permissions).not_to be_empty
    end

    it 'sets the permissions to reviewer/group/edit' do
      permission = @article.permissions.first
      expect(permission.name).to eq('reviewer')
      expect(permission.type).to eq('group')
      expect(permission.access).to eq('edit')
    end
  end

  describe '#to_jq_upload' do
    before do
      @article = Article.new
      @jq_upload = @article.to_jq_upload('title', 120, 'uuid:nn999n999', 'dsid')
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
      expect(@jq_upload['url']).to eq('/articles/uuid:nn999n999/file/dsid')
    end

    it 'sets the thumbnail url' do
      expect(@jq_upload['thumbnail_url']).to eq('fileIcons/default-icon-48x48.png')
    end

    it 'sets the delete url' do
      expect(@jq_upload['delete_url']).to eq('/articles/uuid:nn999n999/file/dsid')
    end

    it 'sets the delete type' do
      expect(@jq_upload['delete_type']).to eq('DELETE')
    end

  end

end
