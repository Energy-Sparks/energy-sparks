module Pupils
  class AnalysisController < ApplicationController
    load_and_authorize_resource :school

    include SchoolAggregation
    include Measurements

    skip_before_action :authenticate_user!
    before_action :check_aggregated_school_in_cache

    def index
      render params[:category] || :index
    end

    def show
      @charts = get_chart_config
    end

    private

    def get_chart_config
      energy = params.require(:energy)
      presentation = params.require(:presentation)
      secondary_presentation = params[:secondary_presentation]

      sub_pages = [energy, presentation, secondary_presentation].compact

      charts = @school.configuration.get_charts(:pupil_analysis_charts, :pupil_analysis_page, *sub_pages)
      raise ActionController::RoutingError.new("Charts for :pupil_analysis_page #{sub_pages.join(' ')} not found") if charts.empty?
      charts
    end
  end
end
