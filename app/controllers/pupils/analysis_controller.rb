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
      @transformations = process_transformations
    end

    private

    def set_school
      @school = School.friendly.find(params[:school_id])
    end

    def process_transformations
      params.fetch(:transformations, []).each_slice(2).map do |(transformation_type, transformation_value)|
        [transformation_type.first.to_sym, transformation_value.first.to_i]
      end
    end
  end
end
