Rails.application.routes.draw do
  root to: 'home#index'

  resources :activity_types
  resources :schools do
    resources :activities
    member do
      get 'usage'
    end
  end

  devise_for :users
  get 'users/index', to: 'users#index'
end
