require 'mustache'
module Equivalences
  class Calculator
    class CalculationError < StandardError; end

    TIME_PERIODS = {
      last_week: { week: 0 },
      last_school_week: { schoolweek: 0 },
      last_work_week: { workweek: 0 },
      last_month: { month: -1 },
      last_year: { year: 0 },
      last_academic_year: { academicyear: 0 }
    }.freeze

    def initialize(school, analytics)
      @school = school
      @analytics = analytics
    end

    def perform(equivalence_type, content = equivalence_type.current_content)
      variables = TemplateInterpolation.new(content).variables(:equivalence).map(&:to_sym)
      data_cy = {}
      data = variables.each_with_object({}) do |variable, data_collection|
        time_period = TIME_PERIODS.fetch(equivalence_type.time_period.to_sym)
        data_collection[variable] = @analytics.front_end_convert(variable, time_period, equivalence_type.meter_type.to_sym)
        I18n.with_locale(:cy) do
          data_cy[variable] = @analytics.front_end_convert(variable, time_period, equivalence_type.meter_type.to_sym)
        end
      end
      relevant = data.values.all? { |values| values[:show_equivalence] }
      from_date = data.values.pluck(:from_date).min
      to_date = data.values.pluck(:to_date).max
      Equivalence.new(school: @school, content_version: content, data: data, data_cy: data_cy, relevant: relevant, from_date: from_date, to_date: to_date)
    rescue EnergySparksNotEnoughDataException, EnergySparksNoMeterDataAvailableForFuelType, EnergySparksMissingPeriodForSpecifiedPeriodChart => e
      raise CalculationError, e.message
    end
  end
end
