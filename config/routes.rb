Rails.application.routes.draw do
  resources :groups
  namespace :apps, path: 'apps/:slug', slug: /\w+/ do
    get '(:version)/qrcode', to: 'qrcode#show', as: 'qrcode', version: /\d+/

    namespace :releases do
      get '', action: :index
      # 查看应用指定主版本号下面的开发版本列表
      get ':version', action: :show, as: 'builds', version: /\d+(.\d+){0,4}/
    end

    resources :changelogs, only: [:edit, :update]
  end

  # app
  get 'apps', to: 'apps#index', as: 'apps'
  get 'apps/new', to: 'apps#new', as: 'new_app'
  post 'apps', to: 'apps#create'

  # 为 web 上传提供的路由，功能还没做
  get 'apps/upload', to: 'apps#upload', as: 'upload_app'
  get 'apps/build/:id', to: 'apps#build', as: 'build_app'

  get 'apps/:slug/auth', to: 'apps#auth', as: 'auth_app', slug: /\w+/
  get 'apps/:slug/(:version)', to: 'apps#show', as: 'app', slug: /\w+/, version: /\d+/
  patch 'apps/:slug', to: 'apps#update', as: 'update_app_slug', slug: /\w+/
  get 'apps/:slug/edit', to: 'apps#edit', as: 'edit_app', slug: /\w+/
  get 'apps/:slug/destroy', to: 'apps#destroy', as: 'destroy_app', slug: /\w+/

  get 'apps/:slug/web_hooks', to: 'web_hooks#index', as: 'web_hooks', slug: /\w+/
  post 'apps/:slug/web_hooks', to: 'web_hooks#create', slug: /\w+/
  post 'apps/:slug/web_hooks/:hook_id/test', to: 'web_hooks#test', as: 'test_web_hooks', slug: /\w+/, hook_id: /\d+/
  delete 'apps/:slug/web_hooks/:hook_id', to: 'web_hooks#destroy', as: 'destroy_web_hook', slug: /\w+/, hook_id: /\d+/

  # dSYM 管理
  resources :dsyms, except: [:show, :edit, :update]

  # 自动代理
  # resources :pacs

  # Deep Links
  # resources :deep_links, except: [:show]

  # 用户
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  get 'users', to: 'users#index', as: 'users'
  get 'users/new', to: 'users#new', as: 'new_user'
  post 'users/create', to: 'users#create', as: 'create_user'
  get 'users/:id/edit', to: 'users#edit', as: 'edit_user'
  patch 'users/:id/update', to: 'users#update', as: 'update_user'
  put 'users/:id/update', to: 'users#update'
  delete 'users/:id', to: 'users#destroy', as: 'user'
  scope :users, module: 'users' do
    get 'active/:token', to: 'activations#edit', as: 'active_user'
    patch 'active/:token', to: 'activations#update'
  end

  authenticate :user do
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
    if Rails.env.development?
      mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql'
    end
  end

  # graphql api
  post '/graphql', to: 'graphql#execute'

  # api
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

  root to: 'dashboards#index'
end
