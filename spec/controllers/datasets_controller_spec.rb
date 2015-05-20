require 'rails_helper'

describe DatasetsController do

  before do
    @user = FactoryGirl.find_or_create(:reviewer)
    allow_any_instance_of(User).to receive(:groups).and_return([])
  end

  describe '#show' do
    let(:dataset) do
      Dataset.create do |a|
        a.apply_permissions(@user)
      end
    end

    after do
      dataset.delete
    end

    context 'user logged in' do
      before do
        sign_in @user
        get :show, id: dataset.id
      end

      it 'renders the show template' do
        expect(assigns(:pid)).to eq(dataset.id)
        expect(assigns(:model)).to eq('dataset')
        expect(assigns(:files)).to eq([])
        expect(response).to be_success
        expect(response).to render_template('datasets/show')
      end
    end

    context 'user not logged in' do
      it 'returns an error' do
        get :show, id: dataset.id
        expect(response).not_to be_success
      end
    end
  end

  describe '#new' do
    it 'renders the new form' do
      sign_in @user
      get :new
      expect(assigns(:dataset)).to be_a(Dataset)
      expect(assigns(:pid)).not_to be_nil
      expect(assigns(:model)).to eq('dataset')
      expect(assigns(:files)).to eq([])
      expect(assigns(:agreement)).to be_a(DatasetAgreement)
      expect(response).to be_success
      expect(response).to render_template('datasets/new')
    end
  end

  describe '#create' do
    before do
      @pid = Sufia::Noid.namespaceize(Sufia::Noid.noidify(SecureRandom.uuid))
    end

    after do
      dataset = Dataset.find(@pid)
      dataset.delete
    end

    it 'creates a new dataset' do
      params = {}
      sign_in @user

      expect {
        post :create, dataset: params, pid: @pid
      }.to change(Dataset,:count).by(1)
      expect(controller).to redirect_to(edit_dataset_path(@pid))
    end
  end


  describe '#edit' do
    let(:dataset) do
      Dataset.create do |a|
        a.apply_permissions(@user)
      end
    end

    after do
      dataset.delete
    end

    it 'renders the edit form' do
      sign_in @user
      get :edit, id: dataset.id
      expect(assigns(:dataset)).to be_a(Dataset)
      expect(assigns(:pid)).not_to be_nil
      expect(assigns(:model)).to eq('dataset')
      expect(assigns(:files)).to eq([])
      expect(assigns(:agreement)).to be_a(DatasetAgreement)
      expect(response).to be_success
      expect(response).to render_template('datasets/edit')
    end
  end

  describe '#update' do
    let(:dataset) do
      Dataset.create do |a|
        a.apply_permissions(@user)
      end
    end

    after do
      dataset.delete
    end

    it 'creates a new dataset' do
      params = {'title' => 'Dataset title'}
      sign_in @user
      expect(dataset.title).to eq([])
      put :update, id: dataset.id, dataset: params, pid: dataset.id
      dataset.reload
      expect(dataset.title).to eq(['Dataset title'])
      expect(controller).to redirect_to(edit_dataset_path(dataset.id))
    end
  end

  describe '#destroy' do
    let(:dataset) do
      Dataset.create do |a|
        a.apply_permissions(@user)
      end
    end

    it 'deletes the dataset' do
      sign_in @user
      expect {
        delete :destroy, id: dataset
      }.to change { Dataset.exists?(dataset.id) }.from(true).to(false)
      expect(controller).to redirect_to(datasets_path)
    end
  end
end