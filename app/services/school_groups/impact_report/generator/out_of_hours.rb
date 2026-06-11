# frozen_string_literal: true

module SchoolGroups
  module ImpactReport
    class Generator
      class OutOfHours < Base
        METRIC_CATEGORY = :energy_efficiency
        METRICS = %i[out_of_hours].freeze
        FUEL_TYPES = %i[electricity gas].freeze
        UNITS = %i[gbp co2 kwh].freeze

        private

        def value(metric)
          model = model(metric[:fuel_type])
          column = column(model, metric[:unit])
          model.where(column.gt(0)).sum(column)
        end

        def number_of_schools(metric) = model(metric[:fuel_type]).count

        def enough_data?(number_of_schools) = number_of_schools.positive?

        def model(fuel)
          { gas: Comparison::AnnualChangeInGasOutOfHoursUse,
            electricity: Comparison::AnnualChangeInElectricityOutOfHoursUse }[fuel]
            .where(school: visible_schools)
        end

        def column(model, unit) = model.arel_table[[:out_of_hours, unit == :gbp ? :gbpcurrent : unit].join('_')]
      end
    end
  end
end
