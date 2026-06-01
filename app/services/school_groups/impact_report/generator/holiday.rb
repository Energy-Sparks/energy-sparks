# frozen_string_literal: true

module SchoolGroups
  class ImpactReport
    class Generator
      class Holiday < Base
        METRICS = %i[previous previous_year].map { |type| [:holiday, type].join('_').to_sym }
        UNITS = %i[gbp kwh].freeze

        private

        def value(fuel, metric, unit)
          model = model(fuel, metric)
          column = column(model, unit)
          -model.where(column.lt(0)).sum(column)
        end

        def number_of_schools(fuel, metric, _unit) = model(fuel, metric).count

        def enough_data?(number_of_schools) = number_of_schools.positive?

        def model(fuel, metric)
          { gas: {
              holiday_previous: Comparison::ChangeInGasHolidayConsumptionPreviousHoliday,
              holiday_previous_year: Comparison::ChangeInGasHolidayConsumptionPreviousYearsHoliday
            },
            electricity: {
              holiday_previous: Comparison::ChangeInElectricityHolidayConsumptionPreviousHoliday,
              holiday_previous_year: Comparison::ChangeInElectricityHolidayConsumptionPreviousYearsHoliday
            } }[fuel][metric]
            .where(school: @impact_report.visible_schools)
        end

        def column(model, unit) = model.arel_table[[:difference, unit == :gbp ? :gbpcurrent : unit].join('_')]
      end
    end
  end
end
