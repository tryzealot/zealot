# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: 'letter_opener' if Rails.env.development?

  root to: 'dashboards#index'

  #############################################
  # User
  #############################################
  devise_for :users, skip: :registrations, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    devise_registration_actions = [:new, :create, :edit, :update]
    if ENV['ZEALOT_DEMO_MODE'] == 'true'
      devise_registration_actions.delete(:edit)
      devise_registration_actions.delete(:update)
    end

    resource :registration,
      only: devise_registration_actions,
      path: 'users',
      path_names: { new: 'sign_up' },
      controller: 'devise/registrations',
      as: :user_registration do
        get :cancel
      end
  end
  #############################################
  # App
  #############################################
  resources :apps do
    resources :schemes do
      resources :channels, except: %i[index show]
    end
  end

  resources :channels, only: %i[index show] do
    resources :web_hooks, only: %i[new create destroy] do
      member do
        get :enable
        get :disable
        get 'test/:event', to: 'web_hooks#test', as: :test
      end
    end

    resources :releases, except: :index, path_names: { new: 'upload' } do
      scope module: :releases do
        get :qrcode, to: 'qrcode#show'
      end

      member do
        post :auth
      end
    end

    scope module: :channels do
      resources :versions, only: %i[index show], id: /(.+)+/
    end
  end

  #############################################
  # Debug File
  #############################################
  resources :debug_files, except: %i[show]

  #############################################
  # Teardown
  #############################################
  resources :teardowns, only: %i[show new create], path_names: { new: 'upload' }

  #############################################
  # Admin
  #############################################
  authenticate :user, ->(user) { user.admin? } do
    namespace :admin do
      resources :users, except: :show
      resources :web_hooks, except: %i[edit update]

      get :background_jobs, to: 'background_jobs#show'
      get :system_info, to: 'system_info#show'

      require 'sidekiq/web'
      require 'sidekiq/cron/web'
      mount Sidekiq::Web => 'sidekiq', as: :sidekiq
    end
  end

  #############################################
  # API v1
  #############################################
  namespace :api do
    namespace :apps do
      post 'upload', to: 'upload#create'

      get 'latest', to: 'latest#show'
      get 'version_exist', to: 'version_exist#show'
      get 'versions', to: 'versions#index'
      get 'versions/(:release_version)', to: 'versions#show'
      get ':slug(/:version)/install', to: 'install_url#show', as: 'install'
      get ':slug(/:version)/download', to: 'download#show', as: 'download'
      get ':id', action: :show
      patch ':id', action: :update
      delete ':id', action: :destroy
      get '', action: :index
    end

    post 'debug_files/upload', to: 'debug_files#create'
    get 'debug_files/download', to: 'debug_files/download#show'
    resources :debug_files, except: %i[create new edit]

    namespace :jenkins do
      get 'projects', to: 'projects#index'
      get 'projects/:project', to: 'projects#show', as: 'project'
      get 'projects/:project/build', to: 'build#create', as: 'project_build'
      get 'projects/:project/status/(:id)', to: 'status#show', as: 'project_status'
    end
  end

  #############################################
  # API v2
  #############################################
  post '/graphql', to: 'graphql#execute'
end
