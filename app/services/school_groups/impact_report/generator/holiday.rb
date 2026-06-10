# frozen_string_literal: true

module SchoolGroups
  class ImpactReport
    class Generator
      class Holiday < Base
        def self.metric_type((holiday, metric))
          [:holiday, holiday, metric].join('_').to_sym
        end

        METRICS_ARRAY = %i[previous previous_year].product(%i[gbp kwh]).freeze
        private_constant :METRICS_ARRAY
        METRICS = METRICS_ARRAY.map { |metric| metric_type(metric) }

        private

        def metric_category
          :energy_efficiency
        end

        def metric_names
          %i[electricity gas].product(METRICS_ARRAY)
        end

        def value(fuel, (holiday, metric))
          model = model(fuel, holiday, metric)
          -model.sum(column(model, metric))
        end

        def number_of_schools(fuel, (holiday, metric))
          model(fuel, holiday, metric).count
        end

        def enough_data?(_fuel, _metric, number_of_schools)
          number_of_schools.positive?
        end

        def model(fuel, holiday, metric)
          model = { gas: {
                      previous: Comparison::ChangeInGasHolidayConsumptionPreviousHoliday,
                      previous_year: Comparison::ChangeInGasHolidayConsumptionPreviousYearsHoliday
                    },
                    electricity: {
                      previous: Comparison::ChangeInElectricityHolidayConsumptionPreviousHoliday,
                      previous_year: Comparison::ChangeInElectricityHolidayConsumptionPreviousYearsHoliday
                    } }[fuel][holiday]
          model.where(school: @impact_report.visible_schools).where(column(model, metric).lt(0))
        end

        def column(model, metric) = model.arel_table[[:difference, metric == :gbp ? :gbpcurrent : metric].join('_')]
      end
    end
  end
end
