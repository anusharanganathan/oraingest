require 'rails_helper'

describe CatalogController do
  before do
    @user = FactoryGirl.find_or_create(:reviewer)
    allow_any_instance_of(User).to receive(:groups).and_return([])
  end

  describe '#index' do
    it 'shows the home page for the user' do
      sign_in @user
      get :index
      expect(response).to be_success
      expect(response).to render_template('catalog/index')
    end
  end
end