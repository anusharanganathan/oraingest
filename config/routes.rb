OraHydra::Application.routes.draw do
  mount Qa::Engine => '/qa'

  root :to => "catalog#index"

  Blacklight.add_routes(self)
  HydraHead.add_routes(self)
  Hydra::BatchEdit.add_routes(self)

  if Rails.env.production?
    devise_for :users, skip: [:sessions]
    devise_scope :user do
      get "users/auth/webauth" => "login#login", as: :new_user_session
      match 'users/sign_out' => 'devise/sessions#destroy', :as => :destroy_user_session, :via => Devise.mappings[:user].sign_out_via
    end
  else
    devise_for :users
  end

  if defined?(Sufia::ResqueAdmin)
    namespace :admin do
      constraints Sufia::ResqueAdmin do
        mount Resque::Server, at: 'queues'
        resources :qs
      end
    end
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

  resources :articles do
    collection do
      delete ':id/permissions', :action => :revoke_permissions
      get ':id/detailed/edit', :action => :edit_detailed, :as => :edit_detailed
      get ':id/file/:dsid', :controller => 'article_files', :action => :show
      delete ':id/file/:dsid', :controller => 'article_files', :action => :destroy
    end
  end

  resources :datasets, :except => :index do
    collection do
      get '/', :controller => 'list_datasets', :action => :index
      get 'page/:page', :controller => 'list_datasets', :action => :index
      get 'activity', :controller => 'list_datasets', :action => :activity, :as => :dashboard_activity
      get 'facet/:id', :controller => 'list_datasets', :action => :facet, :as => :dashboard_facet
      delete ':id/permissions', :action => :revoke_permissions
      get ':id/agreement', :action => :agreement
      get ':id/file/:dsid', :controller => 'dataset_files', :action => :show
      delete ':id/file/:dsid', :controller => 'dataset_files', :action => :destroy
    end
  end

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
