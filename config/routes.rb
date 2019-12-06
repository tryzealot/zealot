# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: 'letter_opener' if Rails.env.development?

  root to: 'dashboards#index'

  #############################################
  # User
  #############################################
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  #############################################
  # App
  #############################################
  resources :apps do
    resources :schemes do
      resources :channels, except: %i[index show] do
        resources :web_hooks, only: %i[new create destroy] do
          member do
            post :test
          end
        end
      end
    end
  end

  resources :channels, only: %i[index show] do
    resources :releases, except: :index, path_names: { new: 'upload' } do # , param: :version, constraints: { version: /\d+/ }
      scope module: :releases do
        get :qrcode, to: 'qrcode#show'
      end

      member do
        post :auth
      end
    end

    scope module: :channels do
      resources :versions, only: :show, id: /\d+(.\d+){0,4}/
    end
  end

  #############################################
  # Debug File
  #############################################
  resources :debug_files, except: [:show]

  #############################################
  # Teardown
  #############################################
  resources :teardowns, only: [:show, :new, :create], path_names: { new: 'upload' }

  #############################################
  # Admin
  #############################################
  authenticate :user, ->(user) { user.admin? } do
    namespace :admin do
      resources :users, except: :show
      get :background_jobs, to: 'background_jobs#show'
      get :system_info, to: 'system_info#show'

      require 'sidekiq/web'
      mount Sidekiq::Web => 'sidekiq', as: :sidekiq

      if Rails.env.development?
        get :graphql_console, to: 'graphql_console#show'
        mount GraphiQL::Rails::Engine, at: 'graphiql', graphql_path: '/graphql', as: :graphiql
      end
    end
  end

  #############################################
  # API v1
  #############################################
  namespace :api do
    namespace :apps do
      post 'upload', to: 'upload#create'

      get 'latest', to: 'latest#show'
      get 'versions', to: 'versions#index'
      get 'versions/(:release_version)', to: 'versions#show'
      get ':slug(/:version)/install', to: 'install_url#show', as: 'install'
      get ':slug(/:version)/download', to: 'download#show', as: 'download'
      get ':id', action: :show
      patch ':id', action: :update
      delete ':id', action: :destroy
      get '', action: :index
    end

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
