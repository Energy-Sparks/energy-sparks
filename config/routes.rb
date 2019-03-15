Rails.application.routes.draw do
  root to: 'home#index'

  get 'for-teachers', to: 'home#for_teachers'
  get 'for-pupils', to: 'home#for_pupils'

  get 'contact', to: 'home#contact'
  get 'enrol', to: 'home#enrol'
  get 'datasets', to: 'home#datasets'
  get 'team', to: 'home#team'
  get 'getting-started', to: 'home#getting_started'
  get 'scoring', to: 'home#scoring'

  get 'data_feeds/:id/:feed_type', to: 'data_feeds#show', as: :data_feed

  get 'help/(:help_page)', to: 'home#help', as: :help

  resources :activity_types
  resources :activity_categories
  resources :calendars do
    scope module: :calendars do
      resources :calendar_events
    end
  end
  resources :scoreboards
  resources :school_groups

  resources :onboarding, path: 'school_setup', only: [:show] do
    scope module: :onboarding do
      resource :consent,        only: [:show, :create], controller: 'consent'
      resource :account,        only: [:new, :create, :edit, :update], controller: 'account'
      resource :school_details, only: [:new, :create, :edit, :update]
      resource :completion,     only: [:new, :create, :show], controller: 'completion'
      resources :meters,        only: [:new, :create, :edit, :update]
      resource :school_times,   only: [:edit, :update]
      resources :inset_days,    only: [:new, :create, :edit, :update, :destroy]
    end
  end

  resources :schools do
    resources :activities
    scope module: :schools do
      resource :activation, only: [:create], controller: :activation
      resource :deactivation, only: [:create], controller: :deactivation
      resources :contacts
      resources :alert_subscriptions

      resources :meters do
        member do
          put :activate
          put :deactivate
        end
      end
      resource :meter_readings_validation, only: [:create]

      resource :configuration, controller: :configuration
      resource :school_group, controller: :school_group
      resource :times, only: [:edit, :update]

      get 'simulations/:id/simulation_detail', to: 'simulations#show_detailed', as: :simulation_detail
      get 'simulations/new_fitted', to: 'simulations#new_fitted', as: :new_fitted_simulation
      get 'simulations/new_exemplar', to: 'simulations#new_exemplar', as: :new_exemplar_simulation
      resources :simulations

      resources :alerts, only: [:index, :show] do
        resource :find_out_more, controller: :find_out_more
      end

      get :alert_reports, to: 'alert_reports#index', as: :alert_reports
      get :chart, to: 'charts#show'
      get :analysis, to: 'analysis#analysis'
      get :main_dashboard_electric, to: 'analysis#main_dashboard_electric'
      get :main_dashboard_gas, to: 'analysis#main_dashboard_gas'
      get :electricity_detail, to: 'analysis#electricity_detail'
      get :gas_detail, to: 'analysis#gas_detail'
      get :main_dashboard_electric_and_gas, to: 'analysis#main_dashboard_electric_and_gas'
      get :boiler_control, to: 'analysis#boiler_control'
      get :heating_model_fitting, to: 'analysis#heating_model_fitting'
      get :test, to: 'analysis#test'
    end

    # Maintain old scoreboard URL
    get '/scoreboard', to: redirect('/schools')

    member do
      get 'awards'
      get 'suggest_activity'
      get 'data_explorer'
      get 'usage'
      get 'compare_daily_usage', to: 'stats#compare_daily_usage'
      get 'compare_hourly_usage', to: 'stats#compare_hourly_usage'
    end
  end

  devise_for :users, controllers: { sessions: "sessions" }

  devise_for :users, skip: :sessions
  scope :admin do
    resources :users
    get 'reports', to: 'reports#index'
    get 'reports/cache_report', to: 'reports#cache_report', as: :cache_report
  end

  namespace :reports do
    get 'amr_validated_readings', to: 'amr_validated_readings#index', as: :amr_validated_readings
    get 'amr_validated_readings/:meter_id', to: 'amr_validated_readings#show', as: :amr_validated_reading
  end

  namespace :admin do
    resources :alert_types, only: [:index, :show] do
      scope module: :alert_types do
        resource :activity_types, only: [:show, :update]
      end
    end
    resources :school_onboardings, path: 'school_setup', only: [:new, :create, :index] do
      scope module: :school_onboardings do
        resource :configuration, only: [:edit, :update], controller: 'configuration'
        resource :email, only: [:new, :create], controller: 'email'
        resource :reminder, only: [:create], controller: 'reminder'
      end
    end
  end

  namespace :teachers do
    resources :schools, only: :show
  end

  namespace :pupils do
    resources :schools, only: :show
  end
end
