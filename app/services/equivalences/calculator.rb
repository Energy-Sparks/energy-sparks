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
      last_academic_year: { academicyear: 0 },
    }.freeze

    def initialize(school, analytics)
      @school = school
      @analytics = analytics
    end

    def perform(equivalence_type, content = equivalence_type.current_content)
      variables = TemplateInterpolation.new(content).variables(:equivalence).map(&:to_sym)
      data = variables.inject({}) do |data_collection, variable|
        time_period = TIME_PERIODS.fetch(equivalence_type.time_period.to_sym)
        data_collection[variable] = @analytics.front_end_convert(variable, time_period, equivalence_type.meter_type.to_sym)
        data_collection
      end
      relevant = data.values.all? {|values| values[:show_equivalence]}
      from_date = data.values.map {|values| values[:from_date]}.min
      to_date = data.values.map {|values| values[:to_date]}.max
      Equivalence.new(school: @school, content_version: content, data: data, relevant: relevant, from_date: from_date, to_date: to_date)
    rescue EnergySparksNotEnoughDataException, EnergySparksNoMeterDataAvailableForFuelType, EnergySparksMissingPeriodForSpecifiedPeriodChart => e
      raise CalculationError, e.message
    end
  end
end
