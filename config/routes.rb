OraHydra::Application.routes.draw do
  mount Qa::Engine => '/qa'

  root :to => "catalog#index"

  Blacklight.add_routes(self)
  HydraHead.add_routes(self)
  Hydra::BatchEdit.add_routes(self)

  devise_for :users, skip: [:sessions]
  devise_scope :user do
    get "users/auth/webauth" => "login#login", as: :new_user_session
    match 'users/sign_out' => 'devise/sessions#destroy', :as => :destroy_user_session, :via => Devise.mappings[:user].sign_out_via
  end
  
  get 'deposit_licence', to: 'static#deposit_licence'
  get 'data_deposit_licence', to: 'static#data_deposit_licence'

  resources 'reviewer_dashboard', :only=>:index do
    collection do
      get 'page/:page', :action => :index
      get 'activity', :action => :activity, :as => :dashboard_activity
      get 'facet/:id', :action => :facet, :as => :dashboard_facet
    end
  end

  resources 'publications', :only=>:index do
    collection do
      get 'page/:page', :action => :index
      get 'activity', :action => :activity, :as => :dashboard_activity
      get 'facet/:id', :action => :facet, :as => :dashboard_facet
    end
  end

  resources :articles
  delete 'articles/:id/permissions', to: 'articles#revoke_permissions'
  get 'articles/:id/detailed/edit', to: 'articles#edit_detailed'
  
  get 'articles/:id/file/:dsid', to: 'article_files#show'
  delete 'articles/:id/file/:dsid', to: 'article_files#destroy'

  resources 'list_datasets', :only=>:index do
    collection do
      get 'page/:page', :action => :index
      get 'activity', :action => :activity, :as => :dashboard_activity
      get 'facet/:id', :action => :facet, :as => :dashboard_facet
    end
  end

  resources :datasets
  delete 'datasets/:id/permissions', to: 'datasets#revoke_permissions'
  get 'datasets/:id/agreement', to: 'datasets#agreement'
  
  get 'datasets/:id/file/:dsid', to: 'dataset_files#show'
  delete 'datasets/:id/file/:dsid', to: 'dataset_files#destroy'

  resources :dataset_agreements

  #mount Hydra::Collections::Engine => '/' 
  mount Sufia::Engine => '/'


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
