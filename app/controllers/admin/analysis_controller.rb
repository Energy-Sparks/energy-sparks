require 'dashboard'

module Admin
  class AnalysisController < AdminController
    before_action :set_school

    include SchoolAggregation
    include Measurements

    before_action :check_aggregated_school_in_cache
    before_action :build_aggregate_school
    before_action :set_measurement_options

    def analysis
      heat_meter = @aggregate_school.all_heat_meters.first
      redirect_to admin_school_analysis_tab_path(@school, tab: :heating_model_fitting, mpan_mprn: heat_meter.mpan_mprn)
    end

    def show
      render_generic_chart_template
    end

    private

    def build_aggregate_school
      # use for heat model fitting tabs
      @aggregate_school = aggregate_school
    end

    def render_generic_chart_template(extra_chart_config = {})
      extra_chart_config[:mpan_mprn] = params[:mpan_mprn] if params[:mpan_mprn].present?

      @measurement = measurement_unit(params[:measurement])

      @chart_config = { y_axis_units: @measurement }.merge(extra_chart_config)

      @title = title_and_chart_configuration[:name]
      @charts = title_and_chart_configuration[:charts]
      @show_measurement_units = title_and_chart_configuration.fetch(:change_measurement_units, true)

      render :generic_chart_template
    end

    def title_and_chart_configuration
      tab = params[:tab].to_sym
      if %i[test heating_model_fitting].include?(tab)
        DashboardConfiguration::DASHBOARD_PAGE_GROUPS[tab]
      else
        @school.configuration.analysis_charts_as_symbols(:analysis_charts)[tab]
      end
    end

    def set_school
      @school = School.friendly.find(params[:school_id])
    end
  end
end
