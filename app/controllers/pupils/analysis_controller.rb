module Pupils
  class AnalysisController < ApplicationController
    before_action :set_school

    include SchoolAggregation
    include Measurements

    before_action :check_aggregated_school_in_cache

    BASE_CHARTS = {
      electricity: {
        when: {
          chart: :group_by_week_electricity,
          title: 'When electricity was used in the last year'
        }
      }
    }.freeze

    def index
      render params[:category] || :index
    end

    def show
      energy = params.require(:energy).to_sym
      presentation = params.require(:presentation).to_sym

      chart_config = BASE_CHARTS.fetch(energy).fetch(presentation)
      @chart_type = chart_config.fetch(:chart)
      @measurement = measurement_unit(params[:measurement])
      @title = chart_config.fetch(:title)
    end

    private

    def set_school
      @school = School.friendly.find(params[:school_id])
    end
  end
end
