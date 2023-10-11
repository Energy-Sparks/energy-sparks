module Pupils
  class AnalysisController < ApplicationController
    load_and_authorize_resource :school

    include SchoolAggregation
    include Measurements

    skip_before_action :authenticate_user!
    before_action :check_aggregated_school_in_cache
    before_action :set_breadcrumbs

    def index
      render params[:category] || :index
    end

    def show
      @chart_type = get_chart_config
      @fuel_type = params.require(:energy)
    end

    private

    def set_breadcrumbs
      @breadcrumbs = [
        { name: I18n.t('dashboards.pupil_dashboard'), href: pupils_school_path(@school) },
        { name: I18n.t('pupils.analysis.explore_data') }
      ]
    end

    def get_chart_config
      energy = params.require(:energy)
      presentation = params.require(:presentation)
      secondary_presentation = params[:secondary_presentation]

      sub_pages = [energy, presentation, secondary_presentation].compact

      charts = @school.configuration.get_charts(:pupil_analysis_charts, :pupil_analysis_page, *sub_pages)
      chart = charts.first
      unless chart
        raise ActionController::RoutingError, "Chart for :pupil_analysis_page #{sub_pages.join(' ')} not found"
      end

      chart
    end
  end
end
