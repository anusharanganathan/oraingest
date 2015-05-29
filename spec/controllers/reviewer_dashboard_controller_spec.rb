require 'rails_helper'

describe ReviewerDashboardController do
  before do
    allow_any_instance_of(User).to receive(:groups).and_return([])
  end
  
  describe 'logged in archivist' do
    before (:each) do
      @user = FactoryGirl.find_or_create(:archivist)
      sign_in @user
      allow_any_instance_of(User).to receive(:groups).and_return([])
    end

    describe '#index' do

      before (:each) do
        get :index
      end

      it 'should be a success' do
        expect(response).to be_success
        expect(response).to render_template('reviewer_dashboard/index')
      end
      it 'should return an array of documents that need to be reviewed' do
        expected_results = Blacklight.solr.get 'select', :params=>{:q => '*:*', :fq=>['active_fedora_model_ssi:Article OR active_fedora_model_ssi:Dataset', '-MediatedSubmission_status_ssim:Approved', '-MediatedSubmission_status_ssim:Draft']}
        expect(assigns(:response)['response']['numFound']).to eql(expected_results['response']['numFound'])
      end
    end
  end
  
  describe 'logged in regular user' do
    before (:each) do
      @user = FactoryGirl.find_or_create(:user)
      sign_in @user
      allow_any_instance_of(User).to receive(:groups).and_return([])
    end

    describe '#index' do
      it 'should return an error' do
        post :index
        expect(response).not_to be_success
      end
    end
  end
  
  describe 'not logged in as a user' do
    describe '#index' do
      it 'should return an error' do
        post :index
        expect(response).not_to be_success
      end
    end
  end
end
