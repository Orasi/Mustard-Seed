Rails.application.routes.draw do
  apipie
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post 'authenticate', to: 'application#authenticate', defaults: {format: :json}

  resources :users, defaults: {format: :json}

  resources :projects
  post 'projects/:project_id/import', to: 'testcases#import', defaults: {format: :json}
  get 'projects/:project_id/testcases/export', to: 'testcases#export', defaults: {format: :json}

  resources :environments, except: :index, defaults: {format: :json}

  resources :testcases, except: :index, defaults: {format: :json}

  resources :teams, defaults: {format: :json}
  post 'teams/:id/user/:user_id', to: 'teams#add_user', defaults: {format: :json}
  post 'teams/:id/project/:project_id', to: 'teams#add_project', defaults: {format: :json}
  delete 'teams/:id/user/:user_id', to: 'teams#remove_user', defaults: {format: :json}
  delete 'teams/:id/project/:project_id', to: 'teams#remove_project', defaults: {format: :json}


  get 'executions/:id/testcase_status', to: 'executions#testcase_status', defaults: {format: :json}
  get 'executions/:id/testcases/:testcase_id', to: 'executions#testcase_detail', defaults: {format: :json}
  get 'executions/:id/environments/:environment_id', to: 'executions#environment_detail', defaults: {format: :json}
  get 'executions/:id/testcase_summary', to: 'executions#testcase_summary', defaults: {format: :json}
  get 'executions/:id/environment_summary', to: 'executions#environment_summary', defaults: {format: :json}
  get 'executions/:id/incomplete', to: 'executions#incomplete_tests', defaults: {format: :json}
  get 'executions/:id/next_test', to: 'executions#next_incomplete_test', defaults: {format: :json}

  post 'executions/close(/:execution_id)(/:project_key)', to: 'executions#close', defaults: {format: :json}
  delete 'executions/:id', to: 'executions#destroy', defaults: {format: :json}

  get 'results/:id', to: 'results#show', defaults: {format: :json}
  post 'results', to: 'results#create', defaults: {format: :json}
  get 'results/:id/screenshot/:screenshot_id', to: 'results#screenshot', defaults: {format: :json}

  get 'screenshot/:token', to: 'screenshots#show', as: :screenshot, defaults: {format: :json}

end
