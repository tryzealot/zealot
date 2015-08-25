Rails.application.routes.draw do

  devise_for :users

  get 'releases/index', to: 'releases#index', as: 'releases'
  post 'releases/upload', to: 'releases#upload', as: 'upload_releases'
  get 'releases/:id', to: 'releases#show', as: 'release'
  get 'releases/:id/edit', to: 'releases#edit', as: 'edit_release'
  patch 'releases/:id', to: 'releases#update'#, as: 'update_release'
  get 'releases/changelog', to: 'releases#changelog', as: 'update_changelog'

  get 'apps', to: 'apps#index', as: 'apps'
  get 'apps/upload', to: 'apps#upload', as: 'upload_app'
  get 'apps/:slug', to: 'apps#show', as: 'app'
  get 'apps/:slug/edit', to: 'apps#edit', as: 'edit_app'
  patch 'apps/:id', to: 'apps#update', as: 'update_app'
  get 'apps/:slug/destroy', to: 'apps#destroy', as: 'destroy_app'
  get 'apps/:slug/:id', to: 'apps#release', as: 'app_release'


  get 'ios/download/:id', to: 'ios#download', as: 'ios_download'
  resources :ios

  get 'wechat/tips', to: 'visitors#wechat', as: 'wechat_tips'

  get 'users/chatroom', to: 'users#chatrooms', as: 'user_chatrooms'
  get 'users/:id/kickoff', to: 'users#kickoff', as: 'user_kickoff_chatrooms'
  get 'users/:id/messages', to: 'users#messages', as: 'user_messages'
  resources :users

  resources :chatrooms

  get 'messages/:id/image', to: 'messages#image', as: 'messages_image'
  resources :messages

  get 'chatrooms/sync/:id', to: 'chatrooms#sync', as: 'sync_messages'

  get 'errors/not_found'
  get 'errors/server_error'

  match '/404', via: :all, to: 'errors#not_found'
  match '/500', via: :all, to: 'errors#server_error'

  get 'qyer/homefeed/index_list', to: 'visitors#feed', as: 'recommends_feed'

  namespace :demo do
    get 'plans/index', to: 'plans#index', as: 'plans'

    get 'plans/record', to: 'plans#record', as: 'record_plans'
  end


  root to: 'visitors#index'

  namespace :api do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: :true) do
      match 'binary/ipa' => 'binary#ipa', :via => :post
      match 'binary/apk' => 'binary#apk', :via => :post

      match 'jenkins/projects' => 'jenkins#projects', :via => :get
      match 'jenkins/project/:project' => 'jenkins#project', :via => :get
      match 'jenkins/:project/build' => 'jenkins#build', :via => :get
      match 'jenkins/:project/abort/(:id)' => 'jenkins#abort', :via => :get
      match 'jenkins/:project/status/(:id)' => 'jenkins#status', :via => :get

      match 'app/upload' => 'app#upload', :via => :post
      match 'app/download/:release_id' => 'app#download', :via => :get, as: 'app_download'
      match 'app/:slug' => 'app#info', :via => :get, as: 'app_info'
      match 'app/:slug(/:release_id)/install' => 'app#install_url', :via => :get, as: 'app_install'

      get 'user/(:id).json', to: 'user#show'

      namespace :demo do
        get 'dayroutes/show.json', to: 'dayroutes#show'
        get 'dayroutes/traffic.json', to: 'dayroutes#traffic'
        get 'dayroutes/update.json', to: 'dayroutes#update'

        get 'dayroutes/list_location.json', to: 'dayroutes#list_location'
        post 'dayroutes/upload_location.json', to: 'dayroutes#upload_location'

        delete 'dayroutes/clear_cache.json', to: 'dayroutes#clear_cache'
      end
    end
  end
end
