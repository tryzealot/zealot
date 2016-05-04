require 'sidekiq/web'

Rails.application.routes.draw do
  resources :pacs

  # jspatch
  get 'app/:key', to: 'jspatches#app', as: 'jspatch_key'
  resources :jspatches

  # release
  get 'releases/index', to: 'releases#index', as: 'releases'
  post 'releases/upload', to: 'releases#upload', as: 'upload_releases'
  get 'releases/changelog', to: 'releases#changelog', as: 'update_changelog'
  get 'releases/:id', to: 'releases#show', as: 'release', id: /\d+/
  patch 'releases/:id', to: 'releases#update', id: /\d+/
  get 'releases/:id/edit', to: 'releases#edit', as: 'edit_release', id: /\d+/

  # app
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

  get 'apps/:slug/web_hooks', to: 'web_hooks#index', as: 'web_hooks', slug: /\w+/
  post 'apps/:slug/web_hooks', to: 'web_hooks#create', slug: /\w+/
  post 'apps/:slug/web_hooks/:hook_id/test', to: 'web_hooks#test', as: 'test_web_hooks', slug: /\w+/, hook_id: /\d+/
  delete 'apps/:slug/web_hooks/:hook_id', to: 'web_hooks#destroy', slug: /\w+/, hook_id: /\d+/

  # user
  devise_for :users
  get 'users/groups', to: 'users#groups', as: 'user_groups'
  get 'users/:id/kickoff', to: 'users#kickoff', as: 'user_kickoff_group'
  get 'users/:id/messages', to: 'users#messages', as: 'user_messages'
  # resources :users
  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end

  # message
  get 'messages/:id/image', to: 'messages#image', as: 'messages_image'
  get 'messages/:id', to: 'messages#destroy', as: 'destroy_message'
  resources :messages

  get 'groups/sync/:id', to: 'groups#sync', as: 'group_sync_messages'
  resources :groups

  # api
  namespace :api do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: :true) do
      get 'jenkins/projects', to: 'jenkins#projects'
      get 'jenkins/project/:project' => 'jenkins#project', as: 'jenkins_project'
      get 'jenkins/:project/build' => 'jenkins#build', as: 'jenkins_build'
      get 'jenkins/:project/abort/(:id)' => 'jenkins#abort'
      get 'jenkins/:project/status/(:id)' => 'jenkins#status'

      post 'app/upload', top: 'app#upload'
      get 'app/download/:release_id' => 'app#download', as: 'app_download'
      # match 'app/:slug' => 'app#info', :via => :get, as: 'app_info'
      get 'app', to: 'app#info', as: 'app_info'
      get 'app/versions', to: 'app#versions', as: 'app_versions'
      get 'app/latest', to: 'app#latest', as: 'app_latest'
      get 'app/changelogs', to: 'app#changelogs', as: 'app_changelogs'
      get 'app/:slug(/:release_id)/install' => 'app#install_url', as: 'app_install'

      get 'user/(:id).json', to: 'user#show'

      get 'patch/app/:key', to: 'patch#index'
    end
  end

  get 'qyer/homefeed/index_list', to: 'visitors#feed', as: 'recommends_feed'

  get 'errors/not_found'
  get 'errors/server_error'

  match '/404', via: :all, to: 'errors#not_found'
  match '/500', via: :all, to: 'errors#server_error'

  root to: 'visitors#index'
end
