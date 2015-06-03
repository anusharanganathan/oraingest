require 'rails_helper'

RSpec.describe ThesesController, type: :controller do

  before do
    @user = FactoryGirl.find_or_create(:reviewer)
    allow_any_instance_of(User).to receive(:groups).and_return([])
  end

  describe '#show' do
    let(:thesis) do
      Thesis.create do |t|
        t.apply_permissions(@user)
      end
    end

    after do
      thesis.delete
    end

    context 'user logged in' do
      before do
        sign_in @user
        get :show, id: thesis.id
      end

      it 'renders the show template' do
        expect(assigns(:pid)).to eq(thesis.id)
        expect(assigns(:model)).to eq('thesis')
        expect(assigns(:files)).to eq([])
        expect(response).to be_success
        expect(response).to render_template('theses/show')
      end
    end

    context 'user not logged in' do
      it 'returns an error' do
        get :show, id: thesis.id
        expect(response).not_to be_success
      end
    end
  end

  describe '#new' do
    it 'renders the new form' do
      sign_in @user
      get :new
      expect(assigns(:thesis)).to be_an(Thesis)
      expect(assigns(:pid)).not_to be_nil
      expect(assigns(:model)).to eq('thesis')
      expect(assigns(:files)).to eq([])
      expect(response).to be_success
      expect(response).to render_template('theses/new')
    end
  end

  describe '#create' do
    before do
      @pid = Sufia::Noid.namespaceize(Sufia::Noid.noidify(SecureRandom.uuid))
    end

    after do
      thesis = Thesis.find(@pid)
      thesis.delete
    end

    it 'creates a new thesis' do
      params = {}.with_indifferent_access
      sign_in @user

      expect {
        post :create, thesis: params, pid: @pid
      }.to change(Thesis,:count).by(1)
      expect(controller).to redirect_to(edit_thesis_path(@pid))
    end

    context 'when no thesis params are present' do
      it 'renders the edit action' do
        sign_in @user
        post :create, pid: @pid
        expect(response).to render_template('theses/edit')
      end
    end
  end

  describe '#edit' do
    let(:thesis) do
      Thesis.create do |t|
        t.apply_permissions(@user)
      end
    end

    after do
      thesis.delete
    end

    it 'renders the edit form' do
      sign_in @user
      get :edit, id: thesis.id
      expect(assigns(:thesis)).to be_a(Thesis)
      expect(assigns(:pid)).not_to be_nil
      expect(assigns(:model)).to eq('thesis')
      expect(assigns(:files)).to eq([])
      expect(response).to be_success
      expect(response).to render_template('theses/edit')
    end
  end

  describe '#update' do
    let(:thesis) do
      Thesis.create do |t|
        t.apply_permissions(@user)
      end
    end

    after do
      thesis.delete
    end

    it 'updates the thesis' do
      params = {'title' => 'Thesis title'}
      sign_in @user
      expect(thesis.title).to eq([])
      put :update, id: thesis.id, thesis: params, pid: thesis.id
      thesis.reload
      expect(thesis.title).to eq(['Thesis title'])
      expect(controller).to redirect_to(edit_thesis_path(thesis.id))
    end
  end

  describe '#destroy' do
    let(:thesis) do
      Thesis.create do |t|
        t.apply_permissions(@user)
      end
    end

    it 'deletes the thesis' do
      sign_in @user
      expect {
        delete :destroy, id: thesis
      }.to change { Thesis.exists?(thesis.id) }.from(true).to(false)
      expect(controller).to redirect_to(theses_path)
    end
  end
end
