Rails.application.routes.draw do
  devise_for :users
  resources :users
  resources :chatrooms
  resources :messages

  get 'chatrooms/sync/:id', to: 'chatrooms#sync', as: 'sync_messages'
  
  root to: 'visitors#index'
  
  namespace :api do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: :true) do
      match 'binary/ipa' => 'binary#ipa', :via => :put
      match 'binary/apk' => 'binary#apk', :via => :put
    end
  end



end
