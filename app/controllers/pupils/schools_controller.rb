module Pupils
  class SchoolsController < ApplicationController
    include ActionView::Helpers::NumberHelper
    include SchoolAggregation
    include DashboardAlerts
    include DashboardTimeline
    include NonPublicSchools

    load_resource

    skip_before_action :authenticate_user!

    before_action only: [:show] do
      redirect_unless_permitted :show
    end
    before_action :set_breadcrumbs

    def show
      authorize! :show_pupils_dash, @school
      @audience = :pupil
      @show_data_enabled_features = show_data_enabled_features?
      setup_default_features
      setup_data_enabled_features if @show_data_enabled_features
      if Flipper.enabled?(:new_dashboards_2024, current_user)
        render :new_show, layout: 'dashboards'
      else
        render :show
      end
    end

  private

    def set_breadcrumbs
      @breadcrumbs = [{ name: I18n.t('dashboards.pupil_dashboard') }]
    end

    def setup_default_features
      @temperature_observations = @school.observations.temperature
      @show_temperature_observations = show_temperature_observations?
      @observations = setup_timeline(@school.observations)
      @programmes_to_prompt = @school.programmes.last_started
    end

    def setup_data_enabled_features
      @dashboard_alerts = setup_alerts(@school.latest_dashboard_alerts.pupil_dashboard, :pupil_dashboard_title, limit: 2)
    end

    def show_temperature_observations?
      site_settings.temperature_recording_month_numbers.include?(Time.zone.today.month)
    end
  end
end
