Pinlinks::Application.routes.draw do
  devise_for :users

  get '/delete_repo/:repo_id', to: 'repos#destroy'  
  get '/:repo_name/delete_link/:link_id', to: 'links#destroy'  
  get '/:repo_name/new_links', to: 'links#new'  
  get '/:user_name/:repo_name', to: 'repos#show'  
  get '/create_links', to: 'links#create'  
  get '/new_repo', to: 'repos#new'  
  get '/:user_name', to: 'repos#list'  
  root :to => 'repos#index'

  match ':controller(/:action(/:id))(.:format)'
end
