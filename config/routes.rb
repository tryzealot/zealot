# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'dashboards#index'

  #############################################
  # User
  #############################################
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    resource :registration,
      only: %i[new create edit update],
      path: 'users',
      path_names: { new: 'sign_up' },
      controller: 'users/registrations',
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

    resources :releases, path_names: { new: 'upload' } do
      scope module: :releases do
        get :install, to: 'install#show'
      end

      scope module: :releases do
        get :qrcode, to: 'qrcode#show'
      end

      member do
        post :auth
      end
    end

    scope module: :channels do
      resources :versions, only: %i[index show], id: /(.+)+/
      resources :branches, only: %i[index]
      resources :release_types, only: %i[index]
    end
  end

  #############################################
  # Debug File
  #############################################
  resources :debug_files, except: %i[show]

  #############################################
  # Teardown
  #############################################
  resources :teardowns, except: %i[edit update], path_names: { new: 'upload' }

  #############################################
  # Download
  #############################################
  namespace :download do
    resources :releases, only: :show do
      member do
        get ':filename', action: :download, filename: /.+/, as: 'filename'
      end
    end

    resources :debug_files, only: :show do
      member do
        get ':filename', action: :download, filename: /.+/, as: 'filename'
      end
    end
  end

  #############################################
  # UDID (iOS)
  #############################################
  get 'udid', to: 'udid#index'
  get 'udid/install', to: 'udid#install'
  post 'udid/retrieve', to: 'udid#create'
  get 'udid/:udid', to: 'udid#show', as: 'udid_result'

  #############################################
  # Health check
  #############################################
  health_check_routes

  #############################################
  # Admin
  #############################################
  authenticate :user, ->(user) { user.admin? } do
    namespace :admin do
      root to: 'settings#index'

      resources :users, except: :show
      resources :web_hooks, except: %i[edit update]
      resources :settings

      resources :background_jobs, only: :index
      resources :system_info, only: :index
      resources :database_analytics, only: :index
      resources :page_analytics, only: :index

      require 'sidekiq/web'
      require 'sidekiq-scheduler/web'

      mount Sidekiq::Web => 'sidekiq', as: :sidekiq
      mount PgHero::Engine, at: 'pghero', as: :pghero
      mount ActiveAnalytics::Engine, at: :analytics
    end
  end

  #############################################
  # Development Only
  #############################################
  mount LetterOpenerWeb::Engine, at: 'letter_opener' if Rails.env.development?

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

      get ':id', action: :show
      patch ':id', action: :update
      delete ':id', action: :destroy
      get '', action: :index
    end

    resources :debug_files, except: %i[new edit create] do
      collection do
        post :upload, action: :create
        get :download, to: 'debug_files/download#show'

        get 'exists/version', to: 'debug_files/exists#version'
        get 'exists/binary', to: 'debug_files/exists#binary'
        get 'exists/uuid', to: 'debug_files/exists#uuid'
      end
    end

    resources :devices, only: %i[update]

    namespace :jenkins do
      get 'projects', to: 'projects#index'
      get 'projects/:project', to: 'projects#show', as: 'project'
      get 'projects/:project/build', to: 'build#create', as: 'project_build'
      get 'projects/:project/status/(:id)', to: 'status#show', as: 'project_status'
    end

    namespace :zealot do
      resources :version, only: :index
    end
  end

  #############################################
  # API v2
  #############################################
  post '/graphql', to: 'graphql#execute'

  match '/', via: [:post, :put, :patch, :delete], to: 'application#raise_not_found', format: false
  match '*unmatched_route', via: :all, to: 'application#raise_not_found', format: false
end
