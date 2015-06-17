require 'rails_helper'

describe ArticlesController do
  before do
    @user = FactoryGirl.find_or_create(:reviewer)
    allow_any_instance_of(User).to receive(:groups).and_return([])
  end

  describe '#index' do
    context 'logged in user' do
      it 'redirects to publications' do
        sign_in @user
        get :index
        expect(controller).to redirect_to(publications_path)
      end
    end

    context 'user not logged in' do
      it 'returns an error' do
        get :index
        expect(response).not_to be_success
      end
    end
  end

  describe '#show' do
    let(:article) do
      Article.create do |a|
        params = {'worktype'  =>  {'typeLabel'  =>  'Journal article'}, 'title'  =>  'test.docx', 'subtitle'  =>  '', 'abstract'  =>  '', 'publication'  =>  {'publicationStatus'  =>  '', 'reviewStatus'  =>  '', 'publisher_attributes'  =>  {'0'  =>  {'agent_attributes'  =>  {'0'  =>  {'name'  =>  '', 'website'  =>  ''}}}}, 'dateAccepted'  =>  '', 'datePublished'  =>  '', 'location'  =>  '', 'hasDocument_attributes'  =>  {'0'  =>  {'doi'  =>  '', 'uri'  =>  '', 'identifier'  =>  '', 'series_attributes'  =>  {'0'  =>  {'title'  =>  ''}}, 'journal_attributes'  =>  {'0'  =>  {'title'  =>  '', 'issn'  =>  '', 'eissn'  =>  '', 'volume'  =>  '', 'issue'  =>  '', 'pages'  =>  ''}}}}}, 'subject'  =>  {'0'  =>  {'subjectLabel'  =>  '', 'subjectAuthority'  =>  '', 'subjectScheme'  =>  ''}}, 'keyword'  =>  [''], 'language'  =>  {'languageLabel'  =>  '', 'languageCode'  =>  '', 'languageAuthority'  =>  '', 'languageScheme'  =>  ''}, 'creation'  =>  {'creator_attributes'  =>  {'0'  =>  {'name'  =>  'Test Two', 'email'  =>  '', 'sameAs'  =>  '', 'role'  =>  ['http://vocab.ox.ac.uk/ora#author'], 'affiliation'  =>  {'name'  =>  '', 'sameAs'  =>  ''}}}}, 'qualifiedRelation'  =>  {'0'  =>  {'entity_attributes'  =>  {'0'  =>  {'title'  =>  '', 'description'  =>  '', 'identifier'  =>  '', 'citation'  =>  ''}}, 'relation'  =>  ''}}, 'oaStatus'  =>  '', 'oaReason'  =>  '', 'refException'  =>  '', 'hasPart'  =>  {'0'  =>  {'type'  =>  'Content', 'identifier'  =>  'content01', 'description'  =>  '', 'accessRights'  =>  {'embargoDate'  =>  {'end'  =>  {'label'  =>  '', 'date'  =>  ''}, 'duration'  =>  {'years'  =>  '', 'months'  =>  ''}, 'start'  =>  {'label'  =>  'Today', 'date'  =>  ''}}, 'embargoRelease'  =>  ''}}}, 'accessRights'  =>  {'embargoStatus'  =>  'Open access', 'embargoDate'  =>  {'end'  =>  {'label'  =>  '', 'date'  =>  ''}, 'duration'  =>  {'years'  =>  '', 'months'  =>  ''}, 'start'  =>  {'label'  =>  'Today', 'date'  =>  ''}}, 'embargoRelease'  =>  ''}, 'funding'  =>  {'funder_attributes'  =>  {'0'  =>  {'agent_attributes'  =>  {'0'  =>  {'name'  =>  ''}}, 'awards_attributes'  =>  {'0'  =>  {'grantNumber'  =>  ''}}, 'funds'  =>  ''}}}, 'license'  =>  {'licenseLabel'  =>  '', 'licenseStatement'  =>  ''}, 'workflows_attributes'  =>  {'0'  =>  {'id'  =>  '_:g70336805082780', 'involves'  =>  '', 'entries_attributes'  =>  {'0'  =>  {'description'  =>  ''}}, 'comments_attributes'  =>  {'0'  =>  {'description'  =>  ''}}}}, 'permissions_attributes'  =>  {'0'  =>  {'type'  =>  'user', 'name'  =>  '', 'access'  =>  ''}}}.with_indifferent_access
        a.apply_permissions(@user)
        MetadataBuilder.new(a).build(params, [], @user.user_key)
      end
    end

    after do
      article.delete
    end

    context 'user logged in' do
      before do
        sign_in @user
        get :show, id: article.id
      end

      it 'renders the show template' do
        expect(assigns(:pid)).to eq(article.id)
        expect(assigns(:model)).to eq('article')
        expect(assigns(:files)).to eq([])
        expect(response).to be_success
        expect(response).to render_template('articles/show')
      end
    end

    context 'user not logged in' do
      it 'returns an error' do
        get :show, id: article.id
        expect(response).not_to be_success
      end
    end
  end

  describe '#new' do
    it 'renders the new form' do
      sign_in @user
      get :new
      expect(assigns(:article)).to be_an(Article)
      expect(assigns(:pid)).not_to be_nil
      expect(assigns(:model)).to eq('article')
      expect(assigns(:files)).to eq([])
      expect(response).to be_success
      expect(response).to render_template('articles/new')
    end
  end

  describe '#create' do
    before do
      @pid = Sufia::Noid.namespaceize(Sufia::Noid.noidify(SecureRandom.uuid))
    end

    after do
      article = Article.find(@pid)
      article.delete
    end
    it 'creates a new article' do
      params = {'worktype'  =>  {'typeLabel'  =>  'Journal article'}, 'title'  =>  'test.docx', 'subtitle'  =>  '', 'abstract'  =>  '', 'publication'  =>  {'publicationStatus'  =>  '', 'reviewStatus'  =>  '', 'publisher_attributes'  =>  {'0'  =>  {'agent_attributes'  =>  {'0'  =>  {'name'  =>  '', 'website'  =>  ''}}}}, 'dateAccepted'  =>  '', 'datePublished'  =>  '', 'location'  =>  '', 'hasDocument_attributes'  =>  {'0'  =>  {'doi'  =>  '', 'uri'  =>  '', 'identifier'  =>  '', 'series_attributes'  =>  {'0'  =>  {'title'  =>  ''}}, 'journal_attributes'  =>  {'0'  =>  {'title'  =>  '', 'issn'  =>  '', 'eissn'  =>  '', 'volume'  =>  '', 'issue'  =>  '', 'pages'  =>  ''}}}}}, 'subject'  =>  {'0'  =>  {'subjectLabel'  =>  '', 'subjectAuthority'  =>  '', 'subjectScheme'  =>  ''}}, 'keyword'  =>  [''], 'language'  =>  {'languageLabel'  =>  '', 'languageCode'  =>  '', 'languageAuthority'  =>  '', 'languageScheme'  =>  ''}, 'creation'  =>  {'creator_attributes'  =>  {'0'  =>  {'name'  =>  'Test Two', 'email'  =>  '', 'sameAs'  =>  '', 'role'  =>  ['http://vocab.ox.ac.uk/ora#author', 'http://vocab.ox.ac.uk/ora#copyrightHolder'], 'affiliation'  =>  {'name'  =>  '', 'sameAs'  =>  ''}}}}, 'qualifiedRelation'  =>  {'0'  =>  {'entity_attributes'  =>  {'0'  =>  {'title'  =>  '', 'description'  =>  '', 'identifier'  =>  '', 'citation'  =>  ''}}, 'relation'  =>  ''}}, 'oaStatus'  =>  '', 'oaReason'  =>  '', 'refException'  =>  '', 'hasPart'  =>  {'0'  =>  {'type'  =>  'Content', 'identifier'  =>  'content01', 'description'  =>  '', 'accessRights'  =>  {'embargoDate'  =>  {'end'  =>  {'label'  =>  '', 'date'  =>  ''}, 'duration'  =>  {'years'  =>  '', 'months'  =>  ''}, 'start'  =>  {'label'  =>  'Today', 'date'  =>  ''}}, 'embargoRelease'  =>  ''}}}, 'accessRights'  =>  {'embargoStatus'  =>  'Open access', 'embargoDate'  =>  {'end'  =>  {'label'  =>  '', 'date'  =>  ''}, 'duration'  =>  {'years'  =>  '', 'months'  =>  ''}, 'start'  =>  {'label'  =>  'Today', 'date'  =>  ''}}, 'embargoRelease'  =>  ''}, 'funding'  =>  {'funder_attributes'  =>  {'0'  =>  {'agent_attributes'  =>  {'0'  =>  {'name'  =>  ''}}, 'awards_attributes'  =>  {'0'  =>  {'grantNumber'  =>  ''}}, 'funds'  =>  ''}}}, 'license'  =>  {'licenseLabel'  =>  '', 'licenseStatement'  =>  ''}, 'workflows_attributes'  =>  {'0'  =>  {'id'  =>  '_:g70336805082780', 'involves'  =>  '', 'entries_attributes'  =>  {'0'  =>  {'description'  =>  ''}}, 'comments_attributes'  =>  {'0'  =>  {'description'  =>  ''}}}}, 'permissions_attributes'  =>  {'0'  =>  {'type'  =>  'user', 'name'  =>  '', 'access'  =>  ''}}}.with_indifferent_access
      sign_in @user

      expect {
        post :create, article: params, pid: @pid
      }.to change(Article,:count).by(1)
      expect(controller).to redirect_to(edit_detailed_articles_path(@pid))
    end
  end

  describe '#edit' do
    let(:article) do
      Article.create do |a|
        params = {'worktype'  =>  {'typeLabel'  =>  'Journal article'}, 'title'  =>  'test.docx', 'subtitle'  =>  '', 'abstract'  =>  '', 'publication'  =>  {'publicationStatus'  =>  '', 'reviewStatus'  =>  '', 'publisher_attributes'  =>  {'0'  =>  {'agent_attributes'  =>  {'0'  =>  {'name'  =>  '', 'website'  =>  ''}}}}, 'dateAccepted'  =>  '', 'datePublished'  =>  '', 'location'  =>  '', 'hasDocument_attributes'  =>  {'0'  =>  {'doi'  =>  '', 'uri'  =>  '', 'identifier'  =>  '', 'series_attributes'  =>  {'0'  =>  {'title'  =>  ''}}, 'journal_attributes'  =>  {'0'  =>  {'title'  =>  '', 'issn'  =>  '', 'eissn'  =>  '', 'volume'  =>  '', 'issue'  =>  '', 'pages'  =>  ''}}}}}, 'subject'  =>  {'0'  =>  {'subjectLabel'  =>  '', 'subjectAuthority'  =>  '', 'subjectScheme'  =>  ''}}, 'keyword'  =>  [''], 'language'  =>  {'languageLabel'  =>  '', 'languageCode'  =>  '', 'languageAuthority'  =>  '', 'languageScheme'  =>  ''}, 'creation'  =>  {'creator_attributes'  =>  {'0'  =>  {'name'  =>  'Test Two', 'email'  =>  '', 'sameAs'  =>  '', 'role'  =>  ['http://vocab.ox.ac.uk/ora#author'], 'affiliation'  =>  {'name'  =>  '', 'sameAs'  =>  ''}}}}, 'qualifiedRelation'  =>  {'0'  =>  {'entity_attributes'  =>  {'0'  =>  {'title'  =>  '', 'description'  =>  '', 'identifier'  =>  '', 'citation'  =>  ''}}, 'relation'  =>  ''}}, 'oaStatus'  =>  '', 'oaReason'  =>  '', 'refException'  =>  '', 'hasPart'  =>  {'0'  =>  {'type'  =>  'Content', 'identifier'  =>  'content01', 'description'  =>  '', 'accessRights'  =>  {'embargoDate'  =>  {'end'  =>  {'label'  =>  '', 'date'  =>  ''}, 'duration'  =>  {'years'  =>  '', 'months'  =>  ''}, 'start'  =>  {'label'  =>  'Today', 'date'  =>  ''}}, 'embargoRelease'  =>  ''}}}, 'accessRights'  =>  {'embargoStatus'  =>  'Open access', 'embargoDate'  =>  {'end'  =>  {'label'  =>  '', 'date'  =>  ''}, 'duration'  =>  {'years'  =>  '', 'months'  =>  ''}, 'start'  =>  {'label'  =>  'Today', 'date'  =>  ''}}, 'embargoRelease'  =>  ''}, 'funding'  =>  {'funder_attributes'  =>  {'0'  =>  {'agent_attributes'  =>  {'0'  =>  {'name'  =>  ''}}, 'awards_attributes'  =>  {'0'  =>  {'grantNumber'  =>  ''}}, 'funds'  =>  ''}}}, 'license'  =>  {'licenseLabel'  =>  '', 'licenseStatement'  =>  ''}, 'permissions_attributes'  =>  {'0'  =>  {'type'  =>  'user', 'name'  =>  '', 'access'  =>  ''}}}.with_indifferent_access
        a.apply_permissions(@user)
        MetadataBuilder.new(a).build(params, [], @user.user_key)
      end
    end

    after do
      article.delete
    end

    it 'renders the edit form' do
      sign_in @user
      get :edit, id: article.id
      # expect(assigns(:pid)).to eq(article.id)
      expect(assigns(:model)).to eq('article')
      expect(assigns(:files)).to eq([])
      expect(response).to be_success
      expect(response).to render_template('articles/edit')
    end
  end

  describe '#edit_detailed' do
    let(:article) do
      Article.create do |a|
        params = {'worktype'  =>  {'typeLabel'  =>  'Journal article'}, 'title'  =>  'test.docx', 'subtitle'  =>  '', 'abstract'  =>  '', 'publication'  =>  {'publicationStatus'  =>  '', 'reviewStatus'  =>  '', 'publisher_attributes'  =>  {'0'  =>  {'agent_attributes'  =>  {'0'  =>  {'name'  =>  '', 'website'  =>  ''}}}}, 'dateAccepted'  =>  '', 'datePublished'  =>  '', 'location'  =>  '', 'hasDocument_attributes'  =>  {'0'  =>  {'doi'  =>  '', 'uri'  =>  '', 'identifier'  =>  '', 'series_attributes'  =>  {'0'  =>  {'title'  =>  ''}}, 'journal_attributes'  =>  {'0'  =>  {'title'  =>  '', 'issn'  =>  '', 'eissn'  =>  '', 'volume'  =>  '', 'issue'  =>  '', 'pages'  =>  ''}}}}}, 'subject'  =>  {'0'  =>  {'subjectLabel'  =>  '', 'subjectAuthority'  =>  '', 'subjectScheme'  =>  ''}}, 'keyword'  =>  [''], 'language'  =>  {'languageLabel'  =>  '', 'languageCode'  =>  '', 'languageAuthority'  =>  '', 'languageScheme'  =>  ''}, 'creation'  =>  {'creator_attributes'  =>  {'0'  =>  {'name'  =>  'Test Two', 'email'  =>  '', 'sameAs'  =>  '', 'role'  =>  ['http://vocab.ox.ac.uk/ora#author', 'http://vocab.ox.ac.uk/ora#copyrightHolder'], 'affiliation'  =>  {'name'  =>  '', 'sameAs'  =>  ''}}}}, 'qualifiedRelation'  =>  {'0'  =>  {'entity_attributes'  =>  {'0'  =>  {'title'  =>  '', 'description'  =>  '', 'identifier'  =>  '', 'citation'  =>  ''}}, 'relation'  =>  ''}}, 'oaStatus'  =>  '', 'oaReason'  =>  '', 'refException'  =>  '', 'hasPart'  =>  {'0'  =>  {'type'  =>  'Content', 'identifier'  =>  'content01', 'description'  =>  '', 'accessRights'  =>  {'embargoDate'  =>  {'end'  =>  {'label'  =>  '', 'date'  =>  ''}, 'duration'  =>  {'years'  =>  '', 'months'  =>  ''}, 'start'  =>  {'label'  =>  'Today', 'date'  =>  ''}}, 'embargoRelease'  =>  ''}}}, 'accessRights'  =>  {'embargoStatus'  =>  'Open access', 'embargoDate'  =>  {'end'  =>  {'label'  =>  '', 'date'  =>  ''}, 'duration'  =>  {'years'  =>  '', 'months'  =>  ''}, 'start'  =>  {'label'  =>  'Today', 'date'  =>  ''}}, 'embargoRelease'  =>  ''}, 'funding'  =>  {'funder_attributes'  =>  {'0'  =>  {'agent_attributes'  =>  {'0'  =>  {'name'  =>  ''}}, 'awards_attributes'  =>  {'0'  =>  {'grantNumber'  =>  ''}}, 'funds'  =>  ''}}}, 'license'  =>  {'licenseLabel'  =>  '', 'licenseStatement'  =>  ''}, 'permissions_attributes'  =>  {'0'  =>  {'type'  =>  'user', 'name'  =>  '', 'access'  =>  ''}}}.with_indifferent_access
        a.apply_permissions(@user)
        MetadataBuilder.new(a).build(params, [], @user.user_key)
      end
    end

    after do
      article.delete
    end

    it 'renders the edit_detailed form' do
      sign_in @user
      get :edit_detailed, id: article.id
      expect(assigns(:pid)).to eq(article.id)
      expect(assigns(:model)).to eq('article')
      expect(assigns(:files)).to eq([])
      expect(response).to be_success
      expect(response).to render_template('articles/edit_detailed')
    end
  end

  describe '#update' do
    let(:article) do
      Article.create do |a|
        a.apply_permissions(@user)
      end
    end

    after do
      article.delete
    end

    it 'creates a new article' do
      params = {'title' => 'Article title'}
      sign_in @user
      expect(article.title).to eq([])
      put :update, id: article.id, article: params, pid: article.id
      article.reload
      expect(article.title).to eq(['Article title'])
      expect(controller).to redirect_to(edit_detailed_articles_path(article.id))
    end
  end

  describe '#destroy' do
    let(:article) do
      Article.create do |a|
        params = {'worktype'  =>  {'typeLabel'  =>  'Journal article'}, 'title'  =>  'test.docx', 'subtitle'  =>  '', 'abstract'  =>  '', 'publication'  =>  {'publicationStatus'  =>  '', 'reviewStatus'  =>  '', 'publisher_attributes'  =>  {'0'  =>  {'agent_attributes'  =>  {'0'  =>  {'name'  =>  '', 'website'  =>  ''}}}}, 'dateAccepted'  =>  '', 'datePublished'  =>  '', 'location'  =>  '', 'hasDocument_attributes'  =>  {'0'  =>  {'doi'  =>  '', 'uri'  =>  '', 'identifier'  =>  '', 'series_attributes'  =>  {'0'  =>  {'title'  =>  ''}}, 'journal_attributes'  =>  {'0'  =>  {'title'  =>  '', 'issn'  =>  '', 'eissn'  =>  '', 'volume'  =>  '', 'issue'  =>  '', 'pages'  =>  ''}}}}}, 'subject'  =>  {'0'  =>  {'subjectLabel'  =>  '', 'subjectAuthority'  =>  '', 'subjectScheme'  =>  ''}}, 'keyword'  =>  [''], 'language'  =>  {'languageLabel'  =>  '', 'languageCode'  =>  '', 'languageAuthority'  =>  '', 'languageScheme'  =>  ''}, 'creation'  =>  {'creator_attributes'  =>  {'0'  =>  {'name'  =>  'Test Two', 'email'  =>  '', 'sameAs'  =>  '', 'role'  =>  ['http://vocab.ox.ac.uk/ora#author'], 'affiliation'  =>  {'name'  =>  '', 'sameAs'  =>  ''}}}}, 'qualifiedRelation'  =>  {'0'  =>  {'entity_attributes'  =>  {'0'  =>  {'title'  =>  '', 'description'  =>  '', 'identifier'  =>  '', 'citation'  =>  ''}}, 'relation'  =>  ''}}, 'oaStatus'  =>  '', 'oaReason'  =>  '', 'refException'  =>  '', 'hasPart'  =>  {'0'  =>  {'type'  =>  'Content', 'identifier'  =>  'content01', 'description'  =>  '', 'accessRights'  =>  {'embargoDate'  =>  {'end'  =>  {'label'  =>  '', 'date'  =>  ''}, 'duration'  =>  {'years'  =>  '', 'months'  =>  ''}, 'start'  =>  {'label'  =>  'Today', 'date'  =>  ''}}, 'embargoRelease'  =>  ''}}}, 'accessRights'  =>  {'embargoStatus'  =>  'Open access', 'embargoDate'  =>  {'end'  =>  {'label'  =>  '', 'date'  =>  ''}, 'duration'  =>  {'years'  =>  '', 'months'  =>  ''}, 'start'  =>  {'label'  =>  'Today', 'date'  =>  ''}}, 'embargoRelease'  =>  ''}, 'funding'  =>  {'funder_attributes'  =>  {'0'  =>  {'agent_attributes'  =>  {'0'  =>  {'name'  =>  ''}}, 'awards_attributes'  =>  {'0'  =>  {'grantNumber'  =>  ''}}, 'funds'  =>  ''}}}, 'license'  =>  {'licenseLabel'  =>  '', 'licenseStatement'  =>  ''}, 'permissions_attributes'  =>  {'0'  =>  {'type'  =>  'user', 'name'  =>  '', 'access'  =>  ''}}}.with_indifferent_access
        a.apply_permissions(@user)
        MetadataBuilder.new(a).build(params, [], @user.user_key)
      end
    end

    it 'deletes the article' do
      sign_in @user
      expect {
        delete :destroy, id: article
      }.to change { Article.exists?(article.id) }.from(true).to(false)
      expect(controller).to redirect_to(publications_path)
    end
  end
end
