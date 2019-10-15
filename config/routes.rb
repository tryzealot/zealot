Rails.application.routes.draw do
  #############################################
  # App
  #############################################
  resources :channels, only: %i[index show] do
    resources :releases, except: :index, path_names: { new: 'upload' } do # , param: :version, constraints: { version: /\d+/ }
      scope module: 'apps' do
        resources :qrcode, only: :index
        resources :download, only: :index
      end

      member do
        post :auth
      end
    end
  end

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

  # Debug File 管理
  resources :debug_files, except: [:show]

  #############################################
  # User
  #############################################
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  resources :users, except: %i[show]
  scope :users, module: 'users' do
    get 'active/:token', to: 'activations#edit', as: 'active_user'
    patch 'active/:token', to: 'activations#update'
  end

  authenticate :user, ->(user) { user.admin? } do
    namespace :admin do
      require 'sidekiq/web'
      mount Sidekiq::Web => 'sidekiq', as: :sidekiq
      mount GraphiQL::Rails::Engine, at: 'graphiql', graphql_path: '/graphql', as: :graphql

      resources :background_jobs, only: [:index]
    end
  end

  #############################################
  # API v2
  #############################################
  namespace :api do
    namespace :v2 do
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
  end

  #############################################
  # API v3
  #############################################
  post '/graphql', to: 'graphql#execute'

  root to: 'dashboards#index'
end
