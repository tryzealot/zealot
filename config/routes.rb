require 'sidekiq/web'

Rails.application.routes.draw do
  resources :pacs

  get 'app/:key', to: 'jspatches#app', as: 'jspatch_key'
  resources :jspatches

  namespace :releases do
    get 'index', to: 'releases#index', as: 'releases'
    post 'upload', to: 'releases#upload', as: 'upload_releases'
    get 'changelog', to: 'releases#changelog', as: 'update_changelog'
    get ':id', to: 'releases#show', as: 'release', id: /\d+/
    patch ':id', to: 'releases#update', id: /\d+/
    get ':id/edit', to: 'releases#edit', as: 'edit_release', id: /\d+/
  end

  get 'apps', to: 'apps#index', as: 'apps'
  get 'apps/new', to: 'apps#new', as: 'new_app'
  post 'apps', to: 'apps#create'
  get 'apps/upload', to: 'apps#upload', as: 'upload_app'
  get 'apps/build/:id', to: 'apps#build', as: 'build_app'
  patch 'apps/:id', to: 'apps#update', as: 'update_app_id', id: /\d+/
  patch 'apps/:slug', to: 'apps#update', as: 'update_app_slug', slug: /\w+/
  get 'apps/:slug', to: 'apps#show', as: 'app', slug: /\w+/
  get 'apps/:slug/auth', to: 'apps#auth', as: 'auth_app', slug: /\w+/
  get 'apps/:slug/edit', to: 'apps#edit', as: 'edit_app', slug: /\w+/
  get 'apps/:slug/destroy', to: 'apps#destroy', as: 'destroy_app', slug: /\w+/
  get 'apps/:slug/branches/(:branch)', to: 'apps#branches', as: 'app_branches', slug: /\w+/, branch: /[-.\/|\w]+/
  get 'apps/:slug/versions/(:version)', to: 'apps#versions', as: 'app_versions', slug: /\w+/, version: /[-.\/|\w]+/

  get 'apps/:slug/releases/(:version)', to: 'releases#index', as: 'releases_version', version: /\d+/
  get 'apps/:slug/:release_id', to: 'apps#release', as: 'app_release', slug: /\w+/, release_id: /\d+/
  # resources :web_hooks

  get 'apps/:slug/web_hooks', to: 'web_hooks#index', as: 'web_hooks', slug: /\w+/
  post 'apps/:slug/web_hooks', to: 'web_hooks#create', slug: /\w+/
  post 'apps/:slug/web_hooks/:hook_id/test', to: 'web_hooks#test', as: 'test_web_hooks', slug: /\w+/, hook_id: /\d+/
  delete 'apps/:slug/web_hooks/:hook_id', to: 'web_hooks#destroy', slug: /\w+/, hook_id: /\d+/

  get 'ios/download/:id', to: 'ios#download', as: 'ios_download', id: /\d+/
  get 'wechat/tips', to: 'visitors#wechat', as: 'wechat_tips'
  resources :ios

  devise_for :users
  get 'users/groups', to: 'users#groups', as: 'user_groups'
  get 'users/:id/kickoff', to: 'users#kickoff', as: 'user_kickoff_group'
  get 'users/:id/messages', to: 'users#messages', as: 'user_messages'
  resources :users
  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end

  get 'messages/:id/image', to: 'messages#image', as: 'messages_image'
  get 'messages/:id', to: 'messages#destroy', as: 'destroy_message'
  resources :messages

  get 'groups/sync/:id', to: 'groups#sync', as: 'group_sync_messages'
  resources :groups

  namespace :api do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: :true) do
      match 'binary/ipa' => 'binary#ipa', :via => :post
      match 'binary/apk' => 'binary#apk', :via => :post

      match 'jenkins/projects' => 'jenkins#projects', :via => :get
      match 'jenkins/project/:project' => 'jenkins#project', :via => :get, as: 'jenkins_project'
      match 'jenkins/:project/build' => 'jenkins#build', :via => :get, as: 'jenkins_build'
      match 'jenkins/:project/abort/(:id)' => 'jenkins#abort', :via => :get
      match 'jenkins/:project/status/(:id)' => 'jenkins#status', :via => :get

      match 'app/upload' => 'app#upload', :via => :post
      match 'app/download/:release_id' => 'app#download', :via => :get, as: 'app_download'
      # match 'app/:slug' => 'app#info', :via => :get, as: 'app_info'
      match 'app' => 'app#info', :via => :get, as: 'app_info'
      match 'app/versions' => 'app#versions', :via => :get, as: 'app_versions'
      match 'app/latest' => 'app#latest', :via => :get, as: 'app_latest'
      match 'app/changelogs' => 'app#changelogs', :via => :get, as: 'app_changelogs'
      match 'app/:slug(/:release_id)/install' => 'app#install_url', :via => :get, as: 'app_install'

      get 'user/(:id).json', to: 'user#show'

      get 'patch/app/:key', to: 'patch#index'

      namespace :demo do
        get 'dayroutes/show.json', to: 'dayroutes#show'
        get 'dayroutes/traffic.json', to: 'dayroutes#traffic'
        get 'dayroutes/update.json', to: 'dayroutes#update'
        get 'dayroutes/cache.json', to: 'dayroutes#cache'

        get 'dayroutes/list_location.json', to: 'dayroutes#list_location'
        post 'dayroutes/upload_location.json', to: 'dayroutes#upload_location'

        delete 'dayroutes/clear_cache.json', to: 'dayroutes#clear_cache'
      end
    end
  end

  get 'qyer/homefeed/index_list', to: 'visitors#feed', as: 'recommends_feed'

  namespace :demo do
    get 'plans/index', to: 'plans#index', as: 'plans'

    get 'plans/record', to: 'plans#record', as: 'record_plans'
  end

  get 'errors/not_found'
  get 'errors/server_error'

  match '/404', via: :all, to: 'errors#not_found'
  match '/500', via: :all, to: 'errors#server_error'

  root to: 'visitors#index'
end
