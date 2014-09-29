Rails.application.routes.draw do
  resources :chatrooms

  resources :messages
  post 'test/upload', to: 'visitors#upload', as: 'upload'
  get 'chatrooms/sync/:id', to: 'chatrooms#sync', as: 'sync_messages'
  
  root to: 'visitors#index'
  devise_for :users
  resources :users
end
