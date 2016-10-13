Rails.application.routes.draw do
  root to: 'home#index'
  get 'home/schools', to: 'home#schools'

  resources :activity_types
  resources :schools do
    resources :activities
  end

  devise_for :users
  get 'users/index', to: 'users#index'
end
