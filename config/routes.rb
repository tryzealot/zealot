Rails.application.routes.draw do
  namespace :apps, path: 'apps/:slug', slug: /\w+/ do
    get '(:version)/qrcode', to: 'qrcode#show', as: 'qrcode', version: /\d+/

    namespace :releases do
      get '', action: :index
      # 查看应用指定主版本号下面的开发版本列表
      get ':version', action: :show, as: 'builds', version: /\d+(.\d+){0,4}/
    end

    resources :changelogs, only: [:edit, :update]
  end

  # jspatch
  get 'app/:key', to: 'jspatches#app', as: 'jspatch_key'
  resources :jspatches

  resources :pacs

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

  # user
  devise_for :users
  # namespace :users do
  # end

  authenticate :user do
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end

  # api
  namespace :api do
    scope module: :v1 do
      get 'jenkins/projects', to: 'jenkins#projects'
      get 'jenkins/project/:project' => 'jenkins#project', as: 'jenkins_project'
      get 'jenkins/:project/build' => 'jenkins#build', as: 'jenkins_build'
      get 'jenkins/:project/abort/(:id)' => 'jenkins#abort'
      get 'jenkins/:project/status/(:id)' => 'jenkins#status'

      get 'patch/app/:key', to: 'patch#index'
    end

    namespace :v2 do
      namespace :apps do
        post 'upload', to: 'upload#create'
        get 'latest', to: 'latest#show'
        get ':slug(/:version)/install', to: 'install_url#show', as: 'install'
        get ':slug(/:version)/download', to: 'download#show', as: 'download'
        get ':id', action: :show
        patch ':id', action: :update
        delete ':id', action: :destroy
        get '', action: :index
      end

      namespace :pacs do
        post 'update', to: 'update#create'
      end

      namespace :licenses do
        get 'valid_phone', to: 'login#show'
        get 'send_phone_code', to: 'login#update'
        post 'login', to: 'login#create'
      end
    end
  end

  root to: 'visitors#index'
end
