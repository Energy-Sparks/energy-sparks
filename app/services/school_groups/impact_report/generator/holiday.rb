# frozen_string_literal: true

module SchoolGroups
  class ImpactReport
    class Generator
      class Holiday < Base
        def self.metric_type((holiday, metric))
          [:holiday, holiday, metric].join('_').to_sym
        end

        METRICS_ARRAY = %i[previous previous_year].product(%i[gbp kwh]).freeze
        METRICS = METRICS_ARRAY.map { |metric| metric_type(metric) }

        private

        def metric_category
          :energy_efficiency
        end

        def metric_names
          %i[electricity gas].product(METRICS_ARRAY)
        end

        def value(fuel, metric)
          model = model(fuel, metric)
          column = column(model, metric)
          -model.where(column.lt(0)).sum(column)
        end

        def number_of_schools(fuel, metric)
          model(fuel, metric).count
        end

        def enough_data?(_fuel, _metric, number_of_schools)
          number_of_schools.positive?
        end

        def model(fuel, (holiday, _metric))
          { gas: {
              previous: Comparison::ChangeInGasHolidayConsumptionPreviousHoliday,
              previous_year: Comparison::ChangeInGasHolidayConsumptionPreviousYearsHoliday
            },
            electricity: {
              previous: Comparison::ChangeInElectricityHolidayConsumptionPreviousHoliday,
              previous_year: Comparison::ChangeInElectricityHolidayConsumptionPreviousYearsHoliday
            } }[fuel][holiday]
            .where(school: @impact_report.visible_schools)
        end

        def column(model, (_holiday, metric))
          model.arel_table[[:difference, metric == :gbp ? :gbpcurrent : metric].join('_')]
        end
      end
    end
  end
end
