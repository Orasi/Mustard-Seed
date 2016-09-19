Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post 'authenticate', to: 'application#authenticate'

  resources :users

  resources :projects
  post 'projects/:project_id/import', to: 'testcases#import'

  resources :environments, except: :index

  resources :testcases, except: :index

  resources :teams
  post 'teams/:id/user/:user_id', to: 'teams#add_user'
  post 'teams/:id/project/:project_id', to: 'teams#add_project'
  delete 'teams/:id/user/:user_id', to: 'teams#remove_user'
  delete 'teams/:id/project/:project_id', to: 'teams#remove_project'


  get 'executions/:id', to: 'executions#show'
  post 'executions/:id', to: 'executions#close'
  delete 'executions/:id', to: 'executions#destroy'

  post 'results', to: 'results#create'
end
