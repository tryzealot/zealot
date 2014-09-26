Rails.application.routes.draw do
  get 'message/index'

  resources :chatrooms

  root to: 'visitors#index'
  devise_for :users
  resources :users
end
