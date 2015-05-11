require "rails_helper"

describe Article do

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
      it { is_expected.to respond_to(:rightsHolderGroup) }
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
end