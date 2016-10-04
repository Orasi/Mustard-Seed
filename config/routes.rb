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


  get 'executions/:id/testcase_status', to: 'executions#testcase_status'
  get 'executions/:id/testcases/:testcase_id', to: 'executions#testcase_detail'
  get 'executions/:id/environments/:environment_id', to: 'executions#environment_detail'
  get 'executions/:id/testcase_summary', to: 'executions#testcase_summary'
  get 'executions/:id/environment_summary', to: 'executions#environment_summary'

  post 'executions/:id', to: 'executions#close'
  post 'executions/:id', to: 'executions#close'
  delete 'executions/:id', to: 'executions#destroy'

  get 'results/:id', to: 'results#show'
  post 'results', to: 'results#create'
  get 'results/:id/screenshot/:screenshot_id', to: 'results#screenshot'

  get 'screenshot/:token', to: 'screenshots#show', as: :screenshot

end
