module Pupils
  class AnalysisController < ApplicationController
    before_action :set_school

    include SchoolAggregation
    include Measurements

    before_action :check_aggregated_school_in_cache

    BASE_CHARTS = {
      electricity: {
        when: :group_by_week_electricity
      }
    }.freeze

    def index
    end

    def show
      energy = params.require(:energy).to_sym
      presentation = params.require(:presentation).to_sym

      @chart_type = BASE_CHARTS.fetch(energy).fetch(presentation)
      @measurement = measurement_unit(params[:measurement])
      @title = @chart_type.to_s.humanize
    end

    private

    def set_school
      @school = School.friendly.find(params[:school_id])
    end
  end
end
