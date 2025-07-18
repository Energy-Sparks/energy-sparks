require 'dashboard'

module Admin
  class ChartPreviewsController < AdminController
    before_action :load_chart_list
    before_action :set_chart_type
    before_action :set_chart_titles
    before_action :set_controls

    def show
      @schools = School.data_enabled.by_name
      @preview_school = School.friendly.find(chart_params[:school_id]) if chart_params[:school_id].present?
      return unless params[:commit] == 'Next school' && @preview_school

      ids = @schools.pluck(:id)
      @preview_school = School.find(ids[ids.find_index(@preview_school.id) + 1])
    end

    private

    def set_chart_type
      @chart_type = chart_params[:chart_type].to_sym if chart_params[:chart_type].present?
    end

    def set_chart_titles
      @title = chart_params[:title] || (@preview_school.present? ? "School: #{@preview_school.name}" : '')
      @subtitle = chart_params[:subtitle] || (@chart_type.present? ? "Chart: #{@chart_type}" : '')
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
      @chart_list = ChartManager::STANDARD_CHART_CONFIGURATION.keys.sort.select { |c| !c.to_s.include?('test') }
    end
  end
end
