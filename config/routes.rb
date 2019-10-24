Rails.application.routes.draw do
  root to: 'home#index'

  get 'for-teachers', to: 'home#for_teachers'
  get 'for-pupils', to: 'home#for_pupils'
  get 'for-management', to: 'home#for_management'
  get 'home-page', to: 'home#show'
  get 'mailchimp-signup', to: 'home#mailchimp_signup'

  get 'contact', to: 'home#contact'
  get 'enrol', to: 'home#enrol'
  get 'datasets', to: 'home#datasets'
  get 'team', to: 'home#team'
  get 'getting-started', to: 'home#getting_started'
  get 'scoring', to: 'home#scoring'
  get 'privacy_and_cookie_policy', to: 'home#privacy_and_cookie_policy', as: :privacy_and_cookie_policy

  get 'data_feeds/dark_sky_temperature_readings/:area_id', to: 'data_feeds/dark_sky_temperature_readings#show', as: :data_feeds_dark_sky_temperature_readings
  get 'data_feeds/solar_pv_tuos_readings/:area_id',  to: 'data_feeds/solar_pv_tuos_readings#show', as: :data_feeds_solar_pv_tuos_readings
  get 'data_feeds/carbon_intensity_readings',  to: 'data_feeds/carbon_intensity_readings#show', as: :data_feeds_carbon_intensity_readings
  get 'data_feeds/:id/:feed_type', to: 'data_feeds#show', as: :data_feed

  resources :activity_types, only: [:index, :show]
  resources :activity_categories, only: [:index]

  resources :calendars, only: [:show] do
    scope module: :calendars do
      resources :calendar_events
    end
  end

  resources :school_groups, only: :show
  resources :scoreboards

  resources :onboarding, path: 'school_setup', only: [:show] do
    scope module: :onboarding do
      resource :consent,        only: [:show, :create], controller: 'consent'
      resource :account,        only: [:new, :create, :edit, :update], controller: 'account'
      resource :school_details, only: [:new, :create, :edit, :update]
      resource :completion,     only: [:new, :create, :show], controller: 'completion'
      resources :meters,        only: [:new, :create, :edit, :update]
      resource :school_times,   only: [:edit, :update]
      resources :inset_days,    only: [:new, :create, :edit, :update, :destroy]
      resources :contacts,      only: [:new, :create, :edit, :update, :destroy]
    end
  end

  resources :schools do
    resources :activities

    scope module: :schools do

      resources :activity_categories, only: [:index]
      resources :activity_types, only: [:index, :show]

      resources :programme_types, only: [:index, :show]
      resources :programmes, only: [:show, :index, :create]

      resource :action, only: [:new]

      resources :temperature_observations, only: [:show, :new, :create, :index, :destroy]
      resources :locations, only: [:new, :edit, :create, :update, :index, :destroy]
      resource :activation, only: [:create], controller: :activation
      resource :deactivation, only: [:create], controller: :deactivation
      resources :contacts
      resources :alert_subscription_events, only: [:index, :show]

      resources :meters do
        member do
          put :activate
          put :deactivate
        end
      end
      resources :low_carbon_hub_installations, only: [:show, :index, :create, :new, :destroy]

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
      get 'analysis/:tab', to: 'analysis#show', as: :analysis_tab
      [
        :main_dashboard_electric, :main_dashboard_gas, :electricity_detail, :gas_detail, :main_dashboard_electric_and_gas,
        :boiler_control, :heating_model_fitting, :storage_heaters, :solar_pv, :carbon_emissions, :test, :cost
      ].each do |tab|
        get "/#{tab}", to: redirect("/schools/%{school_id}/analysis/#{tab}")
      end

      get :timeline, to: 'timeline#show'

      get :inactive, to: 'inactive#show'
      get :aggregated_meter_collection, to: 'aggregated_meter_collections#show'
      post :aggregated_meter_collection, to: 'aggregated_meter_collections#post'

      resources :users, only: [:index, :destroy]
      resources :school_admins, only: [:new, :create, :edit, :update]
      resources :staff, only: [:new, :create, :edit, :update], controller: :staff
      resources :pupils, only: [:new, :create, :edit, :update]

      resource :usage, controller: :usage, only: :show

    end

    # Maintain old scoreboard URL
    get '/scoreboard', to: redirect('/schools')


    member do
      get 'suggest_activity'
    end
  end

  resource :email_unsubscription, only: [:new, :create, :show], controller: :email_unsubscription

  devise_for :users, controllers: { confirmations: 'confirmations', sessions: 'sessions' }

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
    resources :newsletters
    resources :school_groups
    resources :activity_categories, except: [:destroy]
    resources :activity_types
    resource :activity_type_preview, only: :create

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
          resource :preview, only: :create, controller: 'preview'
        end
        resources :reports, only: [:index, :show]
        resources :school_alert_type_exclusions, only: [:index, :destroy, :new, :create]
      end
    end

    resources :equivalence_types
    resource :equivalence_type_preview, only: :create
    resource :equivalences, only: :create

    resources :unsubscriptions, only: [:index]

    resources :calendars, only: [:new, :create, :index, :show]

    resource :content_generation_run, controller: :content_generation_run
    resources :school_onboardings, path: 'school_setup', only: [:new, :create, :index] do
      scope module: :school_onboardings do
        resource :configuration, only: [:edit, :update], controller: 'configuration'
        resource :email, only: [:new, :create, :edit, :update], controller: 'email'
        resource :reminder, only: [:create], controller: 'reminder'
      end
    end
    namespace :reports do
      resources :alert_subscribers, only: :index
    end
    resource :settings, only: [:show, :update]
  end

  namespace :teachers do
    resources :schools, only: :show
  end

  namespace :management do
    resources :schools, only: :show do
      resources :management_priorities, only: :index
    end
  end

  namespace :pupils do
    resource :session, only: [:create]
    resources :schools, only: :show do
      get :analysis, to: 'analysis#index'
      get 'analysis/:energy/:presentation(/:secondary_presentation)', to: 'analysis#show', as: :analysis_tab
    end
  end
end
