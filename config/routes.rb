# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'dashboards#index'

  #############################################
  # User
  #############################################
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    registrations: 'users/registrations',
    confirmations: 'users/confirmations',
  }, skip: :unlocks

  #############################################
  # App
  #############################################
  resources :apps do
    member do
      get :new_owner
      put :update_owner
    end

    resources :collaborators, except: %i[index show]

    resources :schemes, except: %i[show] do
      resources :channels, except: %i[index show]
    end

    resources :debug_files, only: [] do
      collection do
        get ':device', action: :device, as: :device
      end
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
  resources :debug_files do
    member do
      post :reprocess
    end
  end

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
  # UDID (iOS/iPadOS)
  #############################################
  resources :udid, as: :udid, param: :udid, only: %i[ index show edit update ] do
    collection do
      get :qrcode
      get :install
      post :retrieve, action: :create
    end

    member do
      post :register
    end
  end

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

      resources :settings
      resources :users, except: :show do
        member do
          get :lock
          delete :unlock
        end
      end
      resources :web_hooks, except: %i[ show new create ]
      resources :apple_teams, only: %i[ edit update ]
      resources :background_jobs, only: :index
      resources :system_info, only: :index
      resources :database_analytics, only: :index
      resources :apple_keys, except: %i[ edit update ] do
        member do
          put :sync_devices
          get :private_key
        end
      end

      resources :logs, only: %i[ index ] do
        collection do
          get :retrive
        end
      end

      resources :backups do
        collection do
          get :parse_schedule
        end

        member do
          post :enable
          post :disable
          post :perform
          delete :job, action: :cancel_job
          get :archive, action: :download_archive
          delete :archive, action: :destroy_archive
        end
      end

      namespace :service do
        post :restart
        get :status
      end

      mount GoodJob::Engine, at: 'jobs', as: :jobs
      mount PgHero::Engine, at: 'pghero', as: :pghero
    end
  end

  #############################################
  # API v1
  #############################################
  namespace :api do
    resources :users, except: %i[new edit] do
      collection do
        get :me
        get :search
      end

      member do
        post :lock
        delete :unlock
      end
    end

    resources :apps, except: %i[new edit] do
      collection do
        post :upload, to: 'apps/upload#create'

        get :latest, to: 'apps/latest#show'
        get :version_exist, to: 'apps/version_exist#show'
        get :versions, to: 'apps/versions#index'
        get 'versions/(:release_version)', to: 'apps/versions#show'
      end

      resources :schemes, except: %i[new edit], shallow: true do
        resources :channels, except: %i[new edit]
      end

      resources :collaborators, param: :user_id, except: %i[index new edit]
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

    resources :version, only: :index

    match '*unmatched_route', via: :all, to: 'base#raise_not_found', format: :json
  end

  #############################################
  # API v2
  #############################################
  post '/graphql', to: 'graphql#execute'

  #############################################
  # Development Only
  #############################################
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: '/tools/inbox'
    mount GraphiQL::Rails::Engine, at: "/tools/graphiql", graphql_path: "/graphql"
  end

  ############################################
  # URL Friendly
  ############################################
  scope path: ':channel', format: false, as: :friendly_channel do
    get '/overview', to: 'channels#show'
    get '', to: 'releases#index', as: 'releases'
    get 'versions', to: 'channels/versions#index', as: 'versions'
    get 'versions/:name', to: 'channels/versions#show', name: /(.+)+/, as: 'version'
    get 'release_types/:name', to: 'channels/release_types#index', name: /(.+)+/, as: 'release_types'
    get 'branches/:name', to: 'channels/branches#index', name: /(.+)+/, as: 'branches'
    get ':id', to: 'releases#show', as: 'release'
    # get ':id/download', to: 'download/releases#show', as: 'channel_release_download'
  end

  match '/', via: %i[post put patch delete], to: 'application#raise_not_found', format: false
  match '*unmatched_route', via: :all, to: 'application#raise_not_found', format: false
end
