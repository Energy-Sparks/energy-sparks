Rails.application.routes.draw do
  root to: 'home#index'

  get 'about', to: 'home#about'
  get 'contact', to: 'home#contact'
  get 'enrol', to: 'home#enrol'
  get 'datasets', to: 'home#datasets'
  get 'team', to: 'home#team'

  get 'help/(:help_page)', to: 'home#help', as: :help

  resources :activity_types
  resources :activity_categories
  resources :calendars
  resources :schools do
    resources :activities
    get :leaderboard, on: :collection
    member do
      get 'achievements'
      get 'usage'
      get 'daily_usage', to: 'stats#daily_usage'
      get 'compare_hourly_usage', to: 'stats#compare_hourly_usage'
      get 'hourly_usage', to: 'stats#hourly_usage'
    end
  end

  devise_for :users, controllers: {sessions: "sessions"}

  devise_for :users, skip: :sessions
  scope :admin do
    resources :users
  end

end
