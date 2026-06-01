# frozen_string_literal: true

module SchoolGroups
  class ImpactReport
    class Generator
      class OutOfHours < Base
        UNITS = %i[gbp co2 kwh].freeze
        METRICS = %i[out_of_hours].freeze

        private

        def value(fuel, _metric, unit)
          model = model(fuel)
          column = column(model, unit)
          model.where(column.gt(0)).sum(column)
        end

        def number_of_schools(fuel, _metric, _unit) = model(fuel).count

        def enough_data?(number_of_schools) = number_of_schools.positive?

        def model(fuel)
          { gas: Comparison::AnnualChangeInGasOutOfHoursUse,
            electricity: Comparison::AnnualChangeInElectricityOutOfHoursUse }[fuel]
            .where(school: @impact_report.visible_schools)
        end

        def column(model, unit) = model.arel_table[[:out_of_hours, unit == :gbp ? :gbpcurrent : unit].join('_')]
      end
    end
  end
end
