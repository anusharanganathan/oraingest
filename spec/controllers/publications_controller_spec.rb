require 'rails_helper'

describe PublicationsController do
  before do
    @user = FactoryGirl.find_or_create(:reviewer)
    allow_any_instance_of(User).to receive(:groups).and_return([])
  end

  describe '#index' do
    context 'logged in user' do
      it "renders the :index view" do
        sign_in @user
        get :index
        expect(response).to be_success
        expect(response).to render_template('publications/index')
      end
    end

    context 'user not logged in' do
      it 'returns an error' do
        get :index
        expect(response).not_to be_success
      end
    end

  end
end