Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  # Devise routes
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }

  resources :users, only: [:show] do
    resources :after_register, only: [:show, :update], controller: 'after_register' do
      get ':step', action: :show, as: :step
      put ':step', action: :update
      # step :personal_details, :birthdate, :location_details, :experience_details, :skills_hobbies_details, :name_of_company, :company_location, :company_details, :company_employee
    end
  end

  # Root route
  root to: 'pages#home'

  # custom routes
  get 'sign-up', to: 'pages#sign_up', as: :sign_up_choice
  get '/sign-up-choice', to: 'pages#sign_up', as: :new_user_choice

  # Job namespace (Regular jobs routes for jobseekers)
  resources :jobs, only: [:index, :show] do
    collection do
      get :search
    end
    resources :applications, only: [:show, :new, :create]
    resource :favorites, only: [:create, :destroy]
  end

  # Company namespace
  resources :companies, only: [] do
    get 'dashboard', to: 'dashboard#index'
    resources :jobs, module: :company  # This gives you /company/jobs
    resources :applications, only: [:index, :edit, :update]
  end
end
