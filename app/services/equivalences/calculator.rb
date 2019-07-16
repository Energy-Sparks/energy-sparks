# frozen_string_literal: true

require 'mustache'
module Equivalences
  class Calculator
    class CalculationError < StandardError; end

    TIME_PERIODS = {
      last_week: { week: -1 },
      last_school_week: { schoolweek: -1 },
      last_month: { month: -1 },
      last_year: { year: -1 }
    }.freeze

    def initialize(school, analytics)
      @school = school
      @analytics = analytics
    end

    def perform(equivalence_type, content = equivalence_type.current_content)
      variables = TemplateInterpolation.new(content).variables(:equivalence).map(&:to_sym)
      data = variables.each_with_object({}) do |variable, data_collection|
        time_period = TIME_PERIODS.fetch(equivalence_type.time_period.to_sym)
        data_collection[variable] = @analytics.front_end_convert(variable, time_period, equivalence_type.meter_type.to_sym)
      end
      relevant = data.values.all? {|values| values[:show_equivalence]}
      Equivalence.new(school: @school, content_version: content, data: data, relevant: relevant)
    rescue EnergySparksNotEnoughDataException, EnergySparksNoMeterDataAvailableForFuelType, EnergySparksMissingPeriodForSpecifiedPeriodChart => e
      raise CalculationError, e.message
    end
  end
end
