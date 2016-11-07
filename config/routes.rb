Rails.application.routes.draw do
  root to: 'home#index'

  get 'about', to: 'home#about'
  get 'contact', to: 'home#contact'
  get 'enrol', to: 'home#enrol'
  get 'datasets', to: 'home#datasets'
  get 'help/(:help_page)', to: 'home#help', as: :help

  resources :activity_types
  resources :calendars
  resources :schools do
    resources :activities
    get :leaderboard, on: :collection
    member do
      get 'achievements'
      get 'usage'
      get 'daily_usage', to: 'stats#daily_usage'
      get 'hourly_usage', to: 'stats#hourly_usage'
    end
  end

  devise_for :users
  scope :admin do
    resources :users
  end
end
