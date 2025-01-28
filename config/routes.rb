Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  # Devise routes
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  # Root route
  root to: 'pages#home'

  # custom routes
  get 'sign-up', to: 'pages#sign_up', as: :sign_up_choice
  get '/sign-up-choice', to: 'pages#sign_up', as: :new_user_choice

  # User namespace
  resources :users, only: [:show]

  # Job namespace (Regular jobs routes for jobseekers)
  resources :jobs, only: [:index, :show] do
    collection do
      get 'search'  # This gives you /jobs/search
    end
  end

  # Company namespace
  namespace :company do
    get 'dashboard', to: 'dashboard#index'
    resources :jobs  # This gives you /company/jobs
  end
end
