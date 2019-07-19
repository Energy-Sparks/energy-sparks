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

  get 'data_feeds/dark_sky_temperature_readings/:area_id', to: 'data_feeds/dark_sky_temperature_readings#show', as: :data_feeds_dark_sky_temperature_readings
  get 'data_feeds/solar_pv_tuos_readings/:area_id',  to: 'data_feeds/solar_pv_tuos_readings#show', as: :data_feeds_solar_pv_tuos_readings
  get 'data_feeds/carbon_intensity_readings',  to: 'data_feeds/carbon_intensity_readings#show', as: :data_feeds_carbon_intensity_readings
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

      resources :programmes, only: [:show, :index]
      resources :programme_types, only: :show do
        resources :programmes, only: :new
      end

      resource :action, only: [:new]

      resources :temperature_observations, only: [:show, :new, :create, :index, :destroy]
      resource :activation, only: [:create], controller: :activation
      resource :deactivation, only: [:create], controller: :deactivation
      resources :contacts
      resources :alert_subscription_events, only: :index

      resources :meters do
        member do
          put :activate
          put :deactivate
        end
      end
      resource :meter_readings_validation, only: [:create]
      resource :alert_emails, only: [:create]

      resource :configuration, controller: :configuration
      resource :school_group, controller: :school_group
      resource :times, only: [:edit, :update]

      get 'simulations/:id/simulation_detail', to: 'simulations#show_detailed', as: :simulation_detail
      get 'simulations/new_fitted', to: 'simulations#new_fitted', as: :new_fitted_simulation
      get 'simulations/new_exemplar', to: 'simulations#new_exemplar', as: :new_exemplar_simulation
      resources :simulations

      resources :alerts, only: [:show]

      resources :find_out_more, controller: :find_out_more

      resources :interventions

      get :alert_reports, to: 'alert_reports#index', as: :alert_reports
      get :chart, to: 'charts#show'
      get :annotations, to: 'annotations#show'
      get :analysis, to: 'analysis#analysis'
      get :main_dashboard_electric, to: 'analysis#main_dashboard_electric'
      get :main_dashboard_gas, to: 'analysis#main_dashboard_gas'
      get :electricity_detail, to: 'analysis#electricity_detail'
      get :gas_detail, to: 'analysis#gas_detail'
      get :main_dashboard_electric_and_gas, to: 'analysis#main_dashboard_electric_and_gas'
      get :boiler_control, to: 'analysis#boiler_control'
      get :heating_model_fitting, to: 'analysis#heating_model_fitting'
      get :storage_heaters, to: 'analysis#storage_heaters'
      get :solar_pv, to: 'analysis#solar_pv'
      get :carbon_emissions, to: 'analysis#carbon_emissions'
      get :test, to: 'analysis#test'

      get :aggregated_meter_collection, to: 'aggregated_meter_collections#show'
      post :aggregated_meter_collection, to: 'aggregated_meter_collections#post'
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

  resource :email_unsubscription, only: [:new, :create, :show], controller: :email_unsubscription

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
    get 'amr_data_feed_readings', to: 'amr_data_feed_readings#index', as: :amr_data_feed_readings
  end

  namespace :admin do
    namespace :emails do
      resources :alert_mailers, only: :show
    end

    resources :programme_types do
      scope module: :programme_types do
        resource :activity_types, only: [:show, :update]
      end
    end

    resources :alert_types, only: [:index, :show, :edit, :update] do
      scope module: :alert_types do
        resources :ratings, only: [:index, :new, :create, :edit, :update] do
          resource :activity_types, only: [:show, :update]
        end
        namespace :ratings do
          resource :preview, only: :show, controller: 'preview'
        end
      end
    end
    resources :equivalence_types do
      resource :preview, only: :show, controller: 'preview'
    end
    resource :equivalences

    resources :unsubscriptions, only: [:index]

    resources :calendar_areas, only: [:index, :new, :create, :edit, :update]
    resource :content_generation_run, controller: :content_generation_run
    resources :school_onboardings, path: 'school_setup', only: [:new, :create, :index] do
      scope module: :school_onboardings do
        resource :configuration, only: [:edit, :update], controller: 'configuration'
        resource :email, only: [:new, :create], controller: 'email'
        resource :reminder, only: [:create], controller: 'reminder'
      end
    end
    namespace :reports do
      resources :alert_subscribers, only: :index
    end
  end

  namespace :teachers do
    resources :schools, only: :show
  end

  namespace :pupils do
    resources :schools, only: :show
  end
end
