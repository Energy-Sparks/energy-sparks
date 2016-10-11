Rails.application.routes.draw do
  resources :activities
  root to: 'home#index'
  get 'users/index', to: 'users#index'
  devise_for :users

  get 'home/schools', to: 'home#schools'

  resources :meters
  resources :schools
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
