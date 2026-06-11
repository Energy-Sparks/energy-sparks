# frozen_string_literal: true

module SchoolGroups
  module ImpactReport
    class Generator
      class Holiday < Base
        METRIC_CATEGORY = :energy_efficiency
        METRICS = %i[previous previous_year].map { |type| [:holiday, type].join('_').to_sym }
        FUEL_TYPES = %i[electricity gas].freeze
        UNITS = %i[gbp kwh].freeze

        private

        def value(metric)
          model, column = model(metric)
          -model.sum(column)
        end

        def number_of_schools(metric)
          model(metric).first.count
        end

        def enough_data?(number_of_schools) = number_of_schools.positive?

        def model(metric)
          model = { gas: {
                      holiday_previous: Comparison::ChangeInGasHolidayConsumptionPreviousHoliday,
                      holiday_previous_year: Comparison::ChangeInGasHolidayConsumptionPreviousYearsHoliday
                    },
                    electricity: {
                      holiday_previous: Comparison::ChangeInElectricityHolidayConsumptionPreviousHoliday,
                      holiday_previous_year: Comparison::ChangeInElectricityHolidayConsumptionPreviousYearsHoliday
                    } }[metric[:fuel_type]][metric[:metric_type]]
          column = column(model, metric[:unit])
          [model.where(school: visible_schools).where(column.lt(0)), column]
        end

        def column(model, unit) = model.arel_table[[:difference, unit == :gbp ? :gbpcurrent : unit].join('_')]
      end
    end
  end
end
