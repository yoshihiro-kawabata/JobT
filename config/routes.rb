Rails.application.routes.draw do
  root 'jobs#home'

  resources :sessions, only: [:new, :create, :destroy]
  resources :users
  resources :attendances
  resources :consents
  resources :requests

  resources :messages do
    collection do
      get 'ship'
    end
  end

  resources :schedules do
    collection do
      get 'search'
    end
  end

  resources :reports do
    collection do
      get 'search'
    end
  end

  get "/users" =>"users#new"

  get "/sessions/:id" =>"sessions#destroy"

  get 'jobs/home'  
  get 'jobs/manage'
  get 'jobs/attend'
  get 'jobs/leave'
  get 'jobs/data'
  get 'jobs/post'

  get '*path', controller: 'application', action: 'render_404'
  

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
