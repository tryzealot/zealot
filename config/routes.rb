Rails.application.routes.draw do
  resources :chatrooms

  resources :messages
  # get 'chatrooms/messages', to: 'chatrooms#messages'  
  
  root to: 'visitors#index'
  devise_for :users
  resources :users
end
