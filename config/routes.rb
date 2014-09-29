Rails.application.routes.draw do
  resources :chatrooms

  resources :messages
  get 'chatrooms/sync/:id', to: 'chatrooms#sync', as: 'sync_messages'
  
  root to: 'visitors#index'
  devise_for :users
  resources :users
end
