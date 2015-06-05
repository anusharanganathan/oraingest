require 'rails_helper'

describe DashboardController do
  before do
    @routes = Sufia::Engine.routes
  end
  before do
    allow_any_instance_of(User).to receive(:groups).and_return([])
  end
  describe 'logged in user' do
    before (:each) do
      @user = FactoryGirl.find_or_create(:user)
      sign_in @user
      allow_any_instance_of(User).to receive(:groups).and_return([])
    end

    describe '#index' do
      before(:each) do
        get :index
        # Make sure there are at least 3 files owned by @user. Otherwise, the tests aren't meaningful.
        if assigns(:document_list).count < 3
          files_count = assigns(:document_list).count
          until files_count == 3
            gf = GenericFile.new
            gf.apply_depositor_metadata(@user.user_key)
            gf.save
            files_count += 1
          end
          get :index
        end
      end

      after do
        GenericFile.delete_all
      end
      
      it 'should be a success' do
        expect(response).to be_success
        expect(response).to render_template('dashboard/index')
      end

      it 'should return an array of documents I can edit' do
        user_results = Blacklight.solr.get 'select', :params=>{:fq=>["edit_access_group_ssim:public OR edit_access_person_ssim:#{@user.user_key}"]}
        expect(assigns(:response)['response']['numFound']).to eql(user_results['response']['numFound'])
      end

      context 'with render views' do
        render_views
        it 'should paginate' do
          get :index
          expect(response).to be_success
          expect(response).to render_template('dashboard/index')
        end
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
