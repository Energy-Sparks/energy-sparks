Rails.application.routes.draw do
  root to: 'home#index'

  get '/robots.txt' => 'robots_txts#show', as: :robots

  get 'for-schools', to: 'home#for_schools'
  get 'for-teachers', to: redirect('/for-schools')
  get 'for-pupils', to: redirect('/for-schools')
  get 'for-management', to: redirect('/for-schools')

  get 'for-local-authorities', to: 'home#for_local_authorities'
  get 'for-multi-academy-trusts', to: 'home#for_multi_academy_trusts'

  get 'case-studies', to: 'case_studies#index', as: :case_studies
  get 'case_studies/:id/:serve', to: 'case_studies#download'
  get 'case-studies/:id/download', to: 'case_studies#download', as: :case_study_download
  get 'newsletters', to: 'newsletters#index', as: :newsletters
  get 'resources', to: 'resource_files#index', as: :resources
  get 'resources/:id/:serve', to: 'resource_files#download', as: :serve_resource
  get 'jobs', to: 'jobs#index', as: :jobs
  get 'jobs/:id/:serve', to: 'jobs#download'
  get 'home-page', to: 'home#show'
  get 'map', to: 'map#index'
  get 'school_statistics', to: 'home#school_statistics'
  get 'school_statistics_key_data', to: 'home#school_statistics_key_data'

  get 'contact', to: 'home#contact'
  get 'enrol', to: 'home#enrol'
  get 'enrol-our-school', to: 'home#enrol_our_school'
  get 'enrol-our-multi-academy-trust', to: 'home#enrol_our_multi_academy_trust'
  get 'enrol-our-local-authority', to: 'home#enrol_our_local_authority'

  get 'datasets', to: 'home#datasets'
  get 'attribution', to: 'home#attribution'
  get 'child-safeguarding-policy', to: 'home#child_safeguarding_policy'
  get 'user-guide-videos', to: 'home#user_guide_videos' # keep old route for now
  get 'user-guide-youtube', to: redirect('https://www.youtube.com/@energysparksuk') # this is a redirect so it can be used in the sitemap

  get 'team', to: 'home#team'
  get 'funders', to: 'home#funders'
  get 'privacy_and_cookie_policy', to: 'home#privacy_and_cookie_policy', as: :privacy_and_cookie_policy
  get 'support_us', to: 'home#support_us', as: :support_us
  get 'terms_and_conditions', to: 'home#terms_and_conditions', as: :terms_and_conditions
  get 'training', to: 'home#training'
  get 'energy-audits', to: 'home#energy_audits'
  get 'education-workshops', to: 'home#education_workshops'

  get 'data_feeds/dark_sky_temperature_readings/:area_id', to: 'data_feeds/dark_sky_temperature_readings#show', as: :data_feeds_dark_sky_temperature_readings
  get 'data_feeds/solar_pv_tuos_readings/:area_id', to: 'data_feeds/solar_pv_tuos_readings#show', as: :data_feeds_solar_pv_tuos_readings
  get 'data_feeds/carbon_intensity_readings', to: 'data_feeds/carbon_intensity_readings#show', as: :data_feeds_carbon_intensity_readings
  get 'data_feeds/weather_observations/:weather_station_id', to: 'data_feeds/weather_observations#show', as: :data_feeds_weather_observations
  get 'data_feeds/:id/:feed_type', to: 'data_feeds#show', as: :data_feed

  resources :compare, controller: 'compare', param: :benchmark, only: %i[index show] do
    collection do
      get :benchmarks
    end
  end

  # redirect old benchmark URLs
  get '/benchmarks', to: redirect('/compare')
  get '/benchmark', to: redirect(BenchmarkRedirector.new)

  get 'version', to: 'version#show'

  get 'sign_in_and_redirect', to: 'sign_in_and_redirect#redirect'

  resources :help, controller: 'help_pages', only: [:show]

  resources :mailchimp_signups, only: %i[new create index]

  concern :tariff_holder do
    scope module: 'energy_tariffs' do
      resources :energy_tariffs do
        collection do
          get :choose_meters
          get :default_tariffs
          get :smart_meter_tariffs
          get :group_school_tariffs
        end
        member do
          get :choose_type
          get :edit_meters
          get :applies_to
          post :update_meters
          post :update_type
          post :toggle_enabled
          post :update_applies_to
        end
        resources :energy_tariff_flat_prices
        resources :energy_tariff_charges
        resources :energy_tariff_differential_prices do
          collection do
            get :reset
          end
        end
      end
    end
  end

  scope '/admin/settings', as: :admin_settings do
    concerns :tariff_holder
  end

  resources :activity_types, only: [:show] do
    collection do
      get :search
    end
    member do
      get :for_school
    end
  end

  resources :activity_categories, only: %i[index show] do
    collection do
      get :recommended
    end
  end

  resources :programme_types, only: %i[index show]

  resources :intervention_type_groups, only: %i[index show] do
    collection do
      get :recommended
    end
  end

  resources :intervention_types, only: [:show] do
    collection do
      get :search
    end
    member do
      get :for_school
    end
  end

  resources :calendars, only: %i[show destroy] do
    scope module: :calendars do
      resources :calendar_events
    end
    member do
      get :current_events
      post :resync
    end
  end

  resource :school_switcher, only: [:create], controller: :school_switcher

  resources :school_groups, only: [:show] do
    concerns :tariff_holder

    scope module: :school_groups do
      resources :chart_updates, only: [:index] do
        post :bulk_update_charts
      end
      resources :clusters do
        member do
          post :unassign
        end
        collection do
          post :assign
        end
      end
    end
    member do
      get :map
      get :recent_usage
      get :comparisons
      get :priority_actions
      get :current_scores
    end
  end
  resources :scoreboards, only: %i[show index]
  resources :transport_types, only: [:index]

  resources :onboarding, path: 'school_setup', only: [:show] do
    scope module: :onboarding do
      resource :consent,        only: %i[show create], controller: 'consent'
      resource :account,        only: %i[new create edit update], controller: 'account'
      resource :sessions,       only: %i[new destroy], controller: 'sessions'
      resource :clustering,     only: %i[new create], controller: 'clustering'
      resource :school_details, only: %i[new create edit update]
      resource :pupil_account,  only: %i[new create edit update], controller: 'pupil_account'
      resource :completion,     only: %i[new create show], controller: 'completion'
      resources :meters,        only: %i[new create edit update]
      resources :users,         only: %i[index new create edit update destroy]
      resource :school_times,   only: %i[edit update]
      resources :inset_days,    only: %i[new create edit update destroy]
      resources :contacts,      only: %i[new create edit update destroy]
    end
  end

  get 'analysis_page_finder/:urn/:analysis_class', to: 'analysis_page_finder#show', as: :analysis_page_finder

  resources :schools do
    resources :activities do
      member do
        get :completed
      end
    end

    concerns :tariff_holder

    scope module: :schools do
      resource :advice, controller: 'advice', only: [:show] do
        %i[total_energy_use
           baseload
           electricity_costs
           electricity_long_term
           electricity_intraday
           electricity_out_of_hours
           electricity_recent_changes
           heating_control
           thermostatic_control
           gas_costs
           gas_long_term
           gas_out_of_hours
           gas_recent_changes
           hot_water
           solar_pv
           storage_heaters].each do |page|
          resource page, controller: "advice/#{page}", only: [:show] do
            member do
              get :insights
              get :analysis
              get :learn_more
              get :meter_costs if %i[electricity_costs gas_costs].include?(page)
            end
          end
        end
        collection do
          get :priorities
          get :alerts
        end
      end

      resources :analysis, controller: :analysis, only: %i[index show]

      resources :progress, controller: :progress, only: [:index] do
        collection do
          get :electricity
          get :gas
          get :storage_heater
        end
      end

      resources :school_targets do
        scope module: :school_targets do
          resources :progress do
            collection do
              get :electricity
              get :gas
              get :storage_heater
            end
          end
        end
      end

      resources :estimated_annual_consumptions, except: [:show]

      resources :programmes, only: [:create]

      resources :audits

      resources :temperature_observations, only: %i[show new create index destroy]
      resources :transport_surveys, only: %i[show update index destroy], param: :run_on do
        collection do
          get :start
        end
        scope module: :transport_surveys do
          resources :responses, only: %i[index destroy]
        end
      end

      resources :locations, only: %i[new edit create update index destroy]
      resource :visibility, only: %i[create destroy], controller: :visibility
      resource :public, only: %i[create destroy], controller: :public
      resource :data_processing, only: %i[create destroy], controller: :data_processing
      resource :data_enabled, only: %i[create destroy], controller: :data_enabled
      resources :contacts
      resources :subscription_generation_runs, only: %i[index show]
      resources :alert_subscription_events, only: [:show]
      resources :reports, only: [:index]

      resources :meters do
        member do
          get :inventory
          get :n3rgy_status
          put :activate
          put :deactivate
        end
      end

      resources :solar_feeds_configuration, only: [:index]

      resources :solar_edge_installations, only: %i[new show create edit update destroy]
      resources :low_carbon_hub_installations, only: %i[new show create edit update destroy]
      resources :rtone_variant_installations, only: %i[new create edit update destroy]

      resource :meter_readings_validation, only: [:create]

      resource :configuration, controller: :configuration
      resource :school_group, controller: :school_group
      resource :times, only: %i[edit update]
      resource :your_school_estate, only: %i[edit update]

      get 'simulations/:id/simulation_detail', to: 'simulations#show_detailed', as: :simulation_detail
      get 'simulations/new_fitted', to: 'simulations#new_fitted', as: :new_fitted_simulation
      get 'simulations/new_exemplar', to: 'simulations#new_exemplar', as: :new_exemplar_simulation
      resources :simulations

      resources :alerts, only: [:show]
      resources :find_out_more, controller: :find_out_more

      resources :interventions do
        member do
          get :completed
        end
      end

      resources :alert_reports, only: %i[index show]
      resources :benchmark_reports, only: %i[index show]
      resources :benchmark_results, only: [:show]
      resources :content_reports, only: %i[index show]
      resources :equivalence_reports, only: %i[index show]
      get :chart, to: 'charts#show'
      get :annotations, to: 'annotations#show'

      get :timeline, to: 'timeline#show'

      get :inactive, to: 'inactive#show'
      get :live_data, to: 'live_data#show'
      get :private, to: 'private#show'

      resources :cads do
        get :live_data, to: 'cads#live_data'
        get :test, to: 'cads#test'
      end

      post :aggregated_meter_collection, to: 'aggregated_meter_collections#post'

      resources :users do
        member do
          post :make_school_admin
        end
      end
      resources :cluster_admins, only: %i[new create]
      resources :pupils, only: %i[new create edit update]

      resources :consent_documents
      resources :consent_grants, only: %i[index show]

      resource :usage, controller: :usage, only: :show
      resources :downloads, only: [:index]
      resources :batch_runs, only: %i[index create show]

      resource :consents, only: %i[show create]
    end

    # Maintain old scoreboard URL
    get '/scoreboard', to: redirect('/schools')
  end

  resource :email_unsubscription, only: %i[new create show], controller: :email_unsubscription

  devise_for :users, controllers: { confirmations: 'confirmations', sessions: 'sessions', passwords: 'passwords' }

  devise_for :users, skip: :sessions

  get '/admin', to: 'admin#index'

  concern :issueable do
    resources :issues, controller: '/admin/issues' do
      member do
        post :resolve
      end
    end
  end
  concern :messageable do
    resource :dashboard_message, only: %i[update edit destroy], controller: '/admin/dashboard_messages'
  end

  namespace :admin do
    resources :mailer_previews, only: [:index]
    concerns :issueable
    resources :funders
    resources :users do
      get 'unlock', to: 'users#unlock'
      scope module: :users do
        resource :confirmation, only: [:create], controller: 'confirmation'
      end
    end
    resources :advice_pages, only: %i[index edit update] do
      scope module: :advice_pages do
        resource :activity_types, only: %i[show update]
        resource :intervention_types, only: %i[show update]
      end
    end
    resources :case_studies
    resources :dcc_consents, only: [:index]
    post 'dcc_consents/:mpxn/withdraw', to: 'dcc_consents#withdraw', as: :withdraw_dcc_consent
    post 'dcc_consents/:mpxn/grant', to: 'dcc_consents#grant', as: :grant_dcc_consent
    resources :consent_grants, only: %i[index show]
    resources :meters, only: [:index]
    get 'issues/meter_issues/:meter_id', to: 'issues#meter_issues'

    resources :consent_statements
    post 'consent_statements/:id/publish', to: 'consent_statements#publish', as: :publish_consent_statement
    resources :partners
    resources :team_members
    resources :newsletters
    resources :resource_file_types
    resources :resource_files
    resources :jobs
    resources :videos
    resources :school_groups do
      scope module: :school_groups do
        resources :meter_attributes
        resources :meter_updates, only: [:index] do
          post :bulk_update_meter_data_source
          post :bulk_update_meter_procurement_route
        end
        resources :school_onboardings, only: [:index] do
          collection do
            post :reminders
            post :make_visible
          end
        end
        resource :users, only: [:show] do
          get 'unlock', to: 'users#unlock'
        end
        resource :partners, only: %i[show update]
        resource :meter_report, only: [:show] do
          post :deliver, on: :member
        end
        concerns :messageable
        concerns :issueable
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
    resources :intervention_types, except: [:show]

    resources :dark_sky_areas, except: %i[destroy show]
    resources :weather_stations, except: %i[destroy show]
    resources :solar_pv_tuos_areas, except: %i[destroy show]

    resources :schools, only: [] do
      get :analysis, to: 'analysis#analysis'
      get 'analysis/:tab', to: 'analysis#show', as: :analysis_tab
      scope module: :schools do
        concerns :messageable
      end
    end

    namespace :emails do
      resources :alert_mailers, only: :show
    end

    resources :meter_attributes, only: :index
    resources :meter_reviews, only: :index
    resources :meter_statuses, except: :show

    resources :programme_types do
      scope module: :programme_types do
        resource :activity_types, only: %i[show update]
        resources :programmes, only: %i[index create]
      end
    end

    resources :alert_types, only: %i[index show edit update] do
      scope module: :alert_types do
        resources :ratings, only: %i[index new edit create update destroy] do
          resource :activity_types, only: %i[show update]
          resource :intervention_types, only: %i[show update]
        end
        namespace :ratings do
          resource :preview, only: :create, controller: 'preview'
        end
        resources :school_alert_type_exclusions, only: %i[index destroy new create]
      end
    end

    resources :amr_data_feed_configs, only: %i[index show edit update] do
      resources :amr_uploaded_readings, only: %i[index show new create] do
        resources :manual_data_load_runs, only: %i[show create destroy]
      end
    end

    resources :equivalence_types
    resource :equivalence_type_preview, only: :create
    resource :equivalences, only: :create

    resources :unsubscriptions, only: [:index]

    resources :calendars, only: %i[new create index show edit update]

    resources :global_meter_attributes
    resources :consents
    resources :transport_types
    resources :prob_data_reports
    resources :procurement_routes do
      post :deliver
    end
    resources :data_sources do
      post :deliver
      scope module: :data_sources do
        concerns :issueable
      end
    end

    resource :content_generation_run, controller: :content_generation_run
    resources :school_onboardings, path: 'school_setup', only: %i[new create index edit update destroy] do
      scope module: :school_onboardings do
        resource :configuration, only: %i[edit update], controller: 'configuration'
        resource :email, only: %i[new create edit update], controller: 'email'
        resource :reminder, only: [:create], controller: 'reminder'
      end
      collection do
        get 'completed'
      end
    end

    resources :activations, only: :index
    namespace :reports do
      resources :good_jobs, only: :index
      get 'good_jobs/export', to: 'good_jobs#export'
      resources :alert_subscribers, only: :index
      get 'amr_validated_readings', to: 'amr_validated_readings#index', as: :amr_validated_readings
      get 'amr_validated_readings/:meter_id', to: 'amr_validated_readings#show', as: :amr_validated_reading
      get 'amr_validated_readings/summary/:meter_id', to: 'amr_validated_readings#summary', as: :amr_validated_reading_summary, defaults: { format: :json }

      get 'amr_data_feed_readings', to: 'amr_data_feed_readings#index', as: :amr_data_feed_readings, defaults: { format: 'csv' }
      get 'tariffs', to: 'tariffs#index', as: :tariffs
      get 'tariffs/:meter_id', to: 'tariffs#show', as: :tariff
      resources :amr_data_feed_import_logs, only: [:index]
      get 'amr_data_feed_import_logs/errors' => 'amr_data_feed_import_logs#errors'
      get 'amr_data_feed_import_logs/warnings' => 'amr_data_feed_import_logs#warnings'
      get 'amr_data_feed_import_logs/successes' => 'amr_data_feed_import_logs#successes'

      resources :recent_audits, only: [:index]
      resources :tariff_import_logs, only: [:index]
      resources :amr_reading_warnings, only: [:index]
      resources :activities, only: :index
      resources :interventions, only: :index
      resources :school_targets, only: :index
      resources :meter_reports, only: :index
      resources :data_loads, only: :index
      resources :transifex_loads, only: %i[index show]
      resources :activity_types, only: %i[index show]
      resources :dcc_status, only: [:index]
      resources :solar_panels, only: [:index]
      resource :unvalidated_readings, only: [:show]
      resource :funder_allocations, only: [:show] do
        post :deliver
      end
      get 'energy_tariffs', to: 'energy_tariffs#index', as: :energy_tariffs
    end

    resource :settings, only: %i[show update]

    resources :reports, only: [:index]

    namespace :schools do
      resources :meter_collections, only: :index
      resources :removals, only: :index
    end

    resources :schools, only: [:show] do
      resource :unvalidated_amr_data, only: :show
      resource :validated_amr_data, only: :show
      resource :aggregated_meter_collection, only: :show, constraints: ->(request) { request.format == :yaml }
      scope module: :schools do
        resources :meter_attributes
        resources :school_attributes
        resources :school_attributes
        resources :single_meter_attributes, only: [:show]
        resource :partners, only: %i[show update]
        resources :meter_reviews
        resources :consent_requests
        resources :bill_requests
        resource :target_data, only: :show
      end
      member do
        post :archive
        post :archive_meters
        post :delete_meters
        post :deactivate_users
        post :reenable
        get :removal
        post :delete
      end
      concerns :issueable
    end

    authenticate :user, ->(user) { user.admin? } do
      mount GoodJob::Engine => 'good_job'
    end
  end # Admin name space

  get 'admin/mailer_previews/*path' => 'rails/mailers#preview', as: :admin_mailer_preview

  # redirect from old teacher dashboard
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
