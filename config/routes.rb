Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    # 認證路由
    post 'auth/google', to: 'auth#google_login'
    post 'auth/student', to: 'auth#student_login'
    post 'auth/logout', to: 'auth#logout'
    post 'auth/refresh', to: 'auth#refresh'
    get 'auth/me', to: 'auth#me'
    get 'auth/validate', to: 'auth#validate'

    namespace :admin do
      resources :schools, only: [] do
        collection do
          get :pending
        end
        member do
          post :approve
        end
      end
    end

    resources :schools, only: [] do
      collection do
        post :apply
      end
    end

    scope 'schools/:school_id' do
      resources :students, only: [:index, :create, :update, :destroy] do
        collection do
          post :import
        end
      end
      resources :clubs, only: [:index, :create, :update, :destroy] do
        collection do
          post :import
          get :hotness_report
        end
      end
      resources :club_selections, only: [:create]
      resource :setting, only: [:show, :create, :update], controller: 'school_settings'
    end
  end
end
