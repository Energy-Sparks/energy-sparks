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
      @show_data_enabled_features = show_data_enabled_features?
      setup_default_features
      setup_data_enabled_features if @show_data_enabled_features
    end

  private

    def set_breadcrumbs
      @breadcrumbs = [{ name: I18n.t('dashboards.pupil_dashboard') }]
    end

    def setup_default_features
      @temperature_observations = @school.observations.temperature
      @show_temperature_observations = show_temperature_observations?
      @observations = setup_timeline(@school.observations)
      @default_equivalences = default_equivalences
      @programmes_to_prompt = @school.programmes.last_started
    end

    def setup_data_enabled_features
      @dashboard_alerts = setup_alerts(@school.latest_dashboard_alerts.pupil_dashboard, :pupil_dashboard_title, limit: 2)
      equivalence_setup(@school)
    end

    def equivalence_setup(school)
      @equivalences = Equivalences::RelevantAndTimely.new(school).equivalences

      @equivalences_content = @equivalences.map do |equivalence|
        TemplateInterpolation.new(
          equivalence.content_version,
          with_objects: { equivalence_type: equivalence.content_version.equivalence_type },
        ).interpolate(
          :equivalence,
          with: equivalence.formatted_variables
        )
      end
    end

    def show_temperature_observations?
      site_settings.temperature_recording_month_numbers.include?(Time.zone.today.month)
    end

    def default_equivalences
      [
        { measure: I18n.t('pupils.default_equivalences.equivalence_1.measure_html'), equivalence: I18n.t('pupils.default_equivalences.equivalence_1.equivalence'), image_name: 'kettle' },
        { measure: I18n.t('pupils.default_equivalences.equivalence_2.measure_html'), equivalence: I18n.t('pupils.default_equivalences.equivalence_2.equivalence'), image_name: 'onshore_wind_turbine' },
        { measure: I18n.t('pupils.default_equivalences.equivalence_3.measure_html'), equivalence: I18n.t('pupils.default_equivalences.equivalence_3.equivalence'), image_name: 'tree' },
        { measure: I18n.t('pupils.default_equivalences.equivalence_4.measure_html'), equivalence: I18n.t('pupils.default_equivalences.equivalence_4.equivalence'), image_name: 'meal' },
        { measure: I18n.t('pupils.default_equivalences.equivalence_5.measure_html'), equivalence: I18n.t('pupils.default_equivalences.equivalence_5.equivalence'), image_name: 'house' }
      ]
    end
  end
end
