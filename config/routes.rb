Pinlinks::Application.routes.draw do
  devise_for :users


  devise_scope :user do
    get 'register', to: 'devise/registrations#new', as: :register
    get 'login', to: 'devise/sessions#new', as: :login
    get 'logout', to: 'devise/sessions#destroy', as: :logout
  end
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

  
  post '/add_tags_and_describe', to: 'links#add_tags_and_describe'
  post '/add_tags_update_name', to: 'repos#add_tags_update_name'
  get '/repo_search_results', to: 'repos#repo_search_results'
  post '/remove_repo_tag', to: 'repos#remove_tag', as: :remove_repo_tag
  post '/remove_link_tag', to: 'links#remove_tag', as: :remove_link_tag
  post '/delete_repo', to: 'repos#destroy', as: :delete_repo
  post '/delete_link', to: 'links#destroy' , as: :delete_link  
  get '/:repo_name/new_links', to: 'links#new'  
  get '/:user_name/:repo_name', to: 'repos#show'  
  post '/create_links', to: 'links#create'  , as: :create_links 
  post '/create_repos', to: 'repos#create' , as: :create_repo  
  get '/new_repo', to: 'repos#new'  
  get '/:user_name', to: 'repos#list'
  get '/fork_repo/:user_id/:repo_id', to: 'repos#fork'
  root :to => 'repos#index'

  match ':controller(/:action(/:id))(.:format)'

end
