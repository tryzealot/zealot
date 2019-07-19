Rails.application.routes.draw do
  #############################################
  # App
  #############################################
  resources :apps, param: :slug, constraints: { slug: /(?!new)\w+/ }, except: %i[show] do
    member do
      get :auth
      scope '(:version)', version: /\d+/ do
        get :show, as: ''
        get '/qrcode', to: 'apps/qrcode#show', as: 'qrcode'
      end

      resources :web_hooks, param: :hook_id, constraints: { hook_id: /\d+/ }, only: %i[index create destroy] do
        member do
          post :test
        end
      end

      scope module: 'apps', as: 'app' do
        # resources :changelogs, only: %i[edit update]
        resources :releases, param: :version, constraints: { version: /\d+(.\d+){0,4}/ }, only: %i[index show]
      end
    end
  end

  #############################################
  # User
  #############################################
  resources :users, except: %i[show]
  scope :users, module: 'users' do
    get 'active/:token', to: 'activations#edit', as: 'active_user'
    patch 'active/:token', to: 'activations#update'
  end

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  authenticate :user do
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'

    if Rails.env.development?
      mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql'
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

      # namespace :pacs do
      #   post 'update', to: 'update#create'
      # end

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

  #############################################
  # Other
  #############################################
  # dSYM 管理
  resources :dsyms, except: [:show, :edit, :update]

  # # 自动代理
  # resources :pacs

  # # Deep Links
  # resources :deep_links, except: [:show]

  root to: 'dashboards#index'
end
