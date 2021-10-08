Rails.application.routes.draw do
  root to: 'home#index'

  get "/robots.txt" => "robots_txts#show", as: :robots

  get 'for-teachers', to: 'home#for_teachers'
  get 'for-pupils', to: 'home#for_pupils'
  get 'for-management', to: 'home#for_management'
  get 'case-studies', to: 'case_studies#index', as: :case_studies
  get 'case_studies/:id/:serve', to: 'case_studies#download'
  get 'newsletters', to: 'newsletters#index', as: :newsletters
  get 'resources', to: 'resource_files#index', as: :resources
  get 'resources/:id/:serve', to: 'resource_files#download'
  get 'home-page', to: 'home#show'
  get 'map', to: 'map#index'
  get 'school_statistics', to: 'home#school_statistics'
  get 'list', to: 'schools#list'

  get 'contact', to: 'home#contact'
  get 'enrol', to: 'home#enrol'
  get 'datasets', to: 'home#datasets'
  get 'attribution', to: 'home#attribution'
  get 'child-safeguarding-policy', to: 'home#child_safeguarding_policy'
  get 'user-guide-videos', to: 'home#user_guide_videos'
  get 'team', to: 'home#team'
  get 'privacy_and_cookie_policy', to: 'home#privacy_and_cookie_policy', as: :privacy_and_cookie_policy
  get 'terms_and_conditions', to: 'home#terms_and_conditions', as: :terms_and_conditions
  get 'training', to: 'home#training'

  get 'data_feeds/dark_sky_temperature_readings/:area_id', to: 'data_feeds/dark_sky_temperature_readings#show', as: :data_feeds_dark_sky_temperature_readings
  get 'data_feeds/solar_pv_tuos_readings/:area_id',  to: 'data_feeds/solar_pv_tuos_readings#show', as: :data_feeds_solar_pv_tuos_readings
  get 'data_feeds/carbon_intensity_readings',  to: 'data_feeds/carbon_intensity_readings#show', as: :data_feeds_carbon_intensity_readings
  get 'data_feeds/weather_observations/:weather_station_id', to: 'data_feeds/weather_observations#show', as: :data_feeds_weather_observations
  get 'data_feeds/:id/:feed_type', to: 'data_feeds#show', as: :data_feed

  get 'benchmarks', to: 'benchmarks#index'
  get 'benchmark', to: 'benchmarks#show'
  get 'all_benchmarks', to: 'benchmarks#show_all'
  get 'version', to: 'version#show'

  resources :help, controller: 'help_pages', only: [:show]

  resources :mailchimp_signups, only: [:new, :create, :index]

  resources :activity_types, only: [:show]
  resources :activity_categories, only: [:index, :show] do
    collection do
      get :recommended
    end
  end

  resources :programme_types, only: [:index, :show]
  resources :intervention_type_groups, only: [:index, :show]
  resources :intervention_types, only: [:index, :show]
  resources :interventions, only: [:new, :create, :edit, :update, :destroy]

  resources :calendars, only: [:show] do
    scope module: :calendars do
      resources :calendar_events
    end
  end

  resource :school_switcher, only: [:create], controller: :school_switcher

  resources :school_groups, only: [:show, :index]
  resources :scoreboards, only: [:show, :index]

  resources :onboarding, path: 'school_setup', only: [:show] do
    scope module: :onboarding do
      resource :consent,        only: [:show, :create], controller: 'consent'
      resource :account,        only: [:new, :create, :edit, :update], controller: 'account'
      resource :sessions,       only: [:new, :destroy], controller: 'sessions'
      resource :clustering,     only: [:new, :create], controller: 'clustering'
      resource :school_details, only: [:new, :create, :edit, :update]
      resource :pupil_account,  only: [:new, :create, :edit, :update], controller: 'pupil_account'
      resource :completion,     only: [:new, :create, :show], controller: 'completion'
      resources :meters,        only: [:new, :create, :edit, :update]
      resources :users,         only: [:index, :new, :create, :edit, :update, :destroy]
      resource :school_times,   only: [:edit, :update]
      resources :inset_days,    only: [:new, :create, :edit, :update, :destroy]
      resources :contacts,      only: [:new, :create, :edit, :update, :destroy]
    end
  end

  get 'analysis_page_finder/:urn/:analysis_class', to: 'analysis_page_finder#show', as: :analysis_page_finder

  resources :schools do
    resources :activities

    scope module: :schools do

      [
        :main_dashboard_electric, :main_dashboard_gas, :electricity_detail, :gas_detail, :main_dashboard_electric_and_gas,
        :boiler_control, :heating_model_fitting, :storage_heaters, :solar_pv, :carbon_emissions, :test, :cost
      ].each do |tab|
        get "/#{tab}", to: redirect("/schools/%{school_id}/analysis")
      end

      resources :analysis, controller: :analysis, only: [:index, :show]
      resources :progress, controller: :progress, only: [:index] do
        collection do
          get :electricity
          get :gas
          get :storage_heater
        end
      end
      resources :school_targets, except: [:destroy]
      resources :programmes, only: [:create]

      resource :action, only: [:new]

      resources :temperature_observations, only: [:show, :new, :create, :index, :destroy]
      resources :locations, only: [:new, :edit, :create, :update, :index, :destroy]
      resource :visibility, only: [:create, :destroy], controller: :visibility
      resource :public, only: [:create, :destroy], controller: :public
      resource :data_processing, only: [:create, :destroy], controller: :data_processing
      resources :contacts
      resources :subscription_generation_runs, only: [:index, :show]
      resources :alert_subscription_events, only: [:show]

      resources :meters do
        member do
          get :inventory
          put :activate
          put :deactivate
        end
      end

      resources :solar_feeds_configuration, only: [:index]

      resources :solar_edge_installations, only: [:new, :create, :edit, :update, :destroy]
      resources :low_carbon_hub_installations, only: [:new, :show, :create, :edit, :update, :destroy]
      resources :rtone_variant_installations, only: [:new, :create, :edit, :update, :destroy]

      resource :meter_readings_validation, only: [:create]

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

      resources :alert_reports, only: [:index, :show]
      resources :content_reports, only: [:index, :show]
      get :chart, to: 'charts#show'
      get :annotations, to: 'annotations#show'

      get :timeline, to: 'timeline#show'

      get :inactive, to: 'inactive#show'
      get :live_data, to: 'live_data#show'
      get :private, to: 'private#show'

      resources :cads do
        get :live_data, to: 'cads#live_data'
      end

      post :aggregated_meter_collection, to: 'aggregated_meter_collections#post'

      resources :users do
        member do
          post :make_school_admin
        end
      end
      resources :cluster_admins, only: [:new, :create]
      resources :pupils, only: [:new, :create, :edit, :update]

      resources :consent_documents
      resources :consent_grants, only: [:index, :show]

      resource :usage, controller: :usage, only: :show
      resources :downloads, only: [:index]
      resources :batch_runs, only: [:index, :create, :show]

      resource :consents, only: [:show, :create]
      resources :user_tariffs do
        resources :user_tariff_prices, only: [:index, :new, :edit]
        resources :user_tariff_flat_prices
        resources :user_tariff_differential_prices
        resources :user_tariff_charges
        collection do
          get :choose_meters, to: 'user_tariffs#choose_meters'
        end
        member do
          get :choose_type, to: 'user_tariffs#choose_type'
        end
      end

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

  get '/admin', to: 'admin#index'

  namespace :admin do
    resources :users
    resources :case_studies
    resources :dcc_consents, only: [:index]
    post 'dcc_consents/:mpxn/withdraw', to: 'dcc_consents#withdraw', as: :withdraw_dcc_consent
    post 'dcc_consents/:mpxn/grant', to: 'dcc_consents#grant', as: :grant_dcc_consent
    resources :consent_grants, only: [:index, :show]
    resources :meters, only: [:index]
    resources :consent_statements
    post 'consent_statements/:id/publish', to: 'consent_statements#publish', as: :publish_consent_statement
    resources :partners
    resources :team_members
    resources :newsletters
    resources :resource_file_types
    resources :resource_files
    resources :videos
    resources :school_groups do
      scope module: :school_groups do
        resources :meter_attributes
        resources :school_onboardings, only: [:index]
        resource :partners, only: [:show, :update]
      end
    end
    resources :help_pages do
      member do
        put :publish
        put :hide
      end
    end
    resources :scoreboards
    resources :activity_categories, except: [:destroy]
    resources :activity_types
    resource :activity_type_preview, only: :create

    resources :intervention_type_groups, except: [:destroy]
    resources :intervention_types

    resources :dark_sky_areas, except: [:destroy, :show]
    resources :weather_stations, except: [:destroy, :show]
    resources :solar_pv_tuos_areas, except: [:destroy, :show]

    resources :schools, only: [] do
      get :analysis, to: 'analysis#analysis'
      get 'analysis/:tab', to: 'analysis#show', as: :analysis_tab
    end

    namespace :emails do
      resources :alert_mailers, only: :show
    end

    namespace :geo do
      resource :live_data, only: [:show, :create]
    end

    resources :meter_attributes, only: :index
    resources :meter_reviews, only: :index

    resources :programme_types do
      scope module: :programme_types do
        resource :activity_types, only: [:show, :update]
        resources :programmes, only: [:index, :create]
      end
    end

    resources :alert_types, only: [:index, :show, :edit, :update] do
      scope module: :alert_types do
        resources :ratings, only: [:index, :new, :create, :edit, :update] do
          resource :activity_types, only: [:show, :update]
          resource :intervention_types, only: [:show, :update]
        end
        namespace :ratings do
          resource :preview, only: :create, controller: 'preview'
        end
        resources :school_alert_type_exclusions, only: [:index, :destroy, :new, :create]
      end
    end

    resources :amr_data_feed_configs, only: [:index, :show, :edit, :update] do
      resources :amr_uploaded_readings, only: [:index, :show, :new, :create]
    end

    resources :equivalence_types
    resource :equivalence_type_preview, only: :create
    resource :equivalences, only: :create

    resources :unsubscriptions, only: [:index]

    resources :calendars, only: [:new, :create, :index, :show]

    resources :global_meter_attributes
    resources :consents

    resource :content_generation_run, controller: :content_generation_run
    resources :school_onboardings, path: 'school_setup', only: [:new, :create, :index, :edit, :update, :destroy] do
      scope module: :school_onboardings do
        resource :configuration, only: [:edit, :update], controller: 'configuration'
        resource :email, only: [:new, :create, :edit, :update], controller: 'email'
        resource :reminder, only: [:create], controller: 'reminder'
        resources :events, only: [:create]
      end
      collection do
        get 'completed'
      end
    end
    namespace :reports do
      resources :alert_subscribers, only: :index
      get 'amr_validated_readings', to: 'amr_validated_readings#index', as: :amr_validated_readings
      get 'amr_validated_readings/:meter_id', to: 'amr_validated_readings#show', as: :amr_validated_reading
      get 'amr_data_feed_readings', to: 'amr_data_feed_readings#index', as: :amr_data_feed_readings, defaults: { format: 'csv' }
      get 'tariffs', to: 'tariffs#index', as: :tariffs
      get 'tariffs/:meter_id', to: 'tariffs#show', as: :tariff
      resources :benchmark_result_generation_runs, only: [:index, :show]
      resources :amr_data_feed_import_logs, only: [:index]
      resources :tariff_import_logs, only: [:index]
      resources :amr_reading_warnings, only: [:index]
      resources :activities, only: :index
      resources :interventions, only: :index
      resources :school_targets, only: :index
    end

    resource :settings, only: [:show, :update]

    resources :reports, only: [:index]

    namespace :schools do
      resources :meter_collections, only: :index
      resources :removals, only: :index
    end

    resources :schools, only: [:show] do
      resource :unvalidated_amr_data, only: :show
      resource :validated_amr_data, only: :show
      resource :aggregated_meter_collection, only: :show, constraints: lambda { |request| request.format == :yaml }
      scope module: :schools do
        resources :meter_attributes
        resources :school_attributes
        resources :school_attributes
        resources :single_meter_attributes, only: [:show]
        resource :partners, only: [:show, :update]
        resources :meter_reviews
        resources :consent_requests
        resources :bill_requests
        resource :target_data, only: :show
      end
      member do
        get :removal
        post :deactivate_meters
        post :deactivate_users
        post :deactivate
      end
    end

    post 'amr_data_feed_readings/:amr_uploaded_reading_id', to: 'amr_data_feed_readings#create', as: :create_amr_data_feed_readings

  end # Admin name space

  #redirect from old teacher dashboard
  namespace :teachers do
    get '/schools/:name', to: redirect('/management/schools/%{name}')
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
