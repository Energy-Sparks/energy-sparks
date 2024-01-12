require 'dashboard'

module Admin
  class ChartPreviewsController < AdminController
    before_action :set_school
    before_action :load_chart_list
    before_action :set_chart_type
    before_action :set_chart_titles
    before_action :set_controls

    def index
      @schools = School.data_enabled.by_name
    end

    private

    def set_school
      return nil unless chart_params[:school_id].present?
      @preview_school = School.friendly.find(chart_params[:school_id])
    end

    def set_chart_type
      return nil unless chart_params[:chart_type].present?
      @chart_type = chart_params[:chart_type].to_sym
    end

    def set_chart_titles
      @title = chart_params[:title] || @preview_school.present? ? "School: #{@preview_school.name}" : ''
      @subtitle = chart_params[:subtitle] || @chart_type.present? ? "Chart: #{@chart_type}" : ''
      @footer = chart_params[:footer]
    end

    def set_controls
      @axis_controls = chart_params[:axis_controls].nil? || chart_params[:axis_controls] == '1'
      @analysis_controls = chart_params[:analysis_controls].nil? || chart_params[:analysis_controls] == '1'
    end

    def chart_params
      params[:preview_chart] || {}
    end

    def load_chart_list
      analysis_charts = DashboardConfiguration::DASHBOARD_PAGE_GROUPS.except(:simulator, :simulator_detail, :simulator_debug, :test, :pupil_analysis_page, :heating_model_fitting, :cost_unused).map do |top_level_key, config|
        ["#{config[:name]} (#{top_level_key})", config.fetch(:charts) {[]}]
      end
      custom_activity_charts = [['Activity charts (custom)', ChartManager::STANDARD_CHART_CONFIGURATION.keys.grep(/^activities/)]]
      @chart_list = custom_activity_charts + analysis_charts
    end
  end
end
