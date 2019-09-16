module Pupils
  class AnalysisController < ApplicationController
    before_action :set_school

    include SchoolAggregation
    include Measurements

    before_action :check_aggregated_school_in_cache

    def index
      render params[:category] || :index
    end

    def show
      @chart_type = get_chart_config
    end

    private

    def set_school
      @school = School.friendly.find(params[:school_id])
    end

    def get_chart_config
      energy = params.require(:energy)
      presentation = params.require(:presentation)
      secondary_presentation = params[:secondary_presentation]

      dashboard_config = DashboardConfiguration::DASHBOARD_PAGE_GROUPS[:pupil_analysis_page]
      base_chart_config = [energy, presentation, secondary_presentation].compact.inject(dashboard_config) do |config, page_name|
        config[:sub_pages].find {|page| page[:name].downcase == page_name}
      end
      base_chart_config[:charts].first
    end
  end
end
