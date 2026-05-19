# frozen_string_literal: true

module SchoolGroups
  class ImpactReport
    class Generator
      class OutOfHours < Base
        def self.metric_type(metric)
          [:out_of_hours, metric].join('_')
        end

        TYPES = %i[gbp co2 kwh].freeze
        private_constant :METRICS
        METRICS = TYPES.map { |type| metric_type(type) }.freeze

        private

        def metric_category
          :energy_efficiency
        end

        def value(fuel, metric)
          model = model(fuel)
          column = column(model, metric)
          model.where(column.gt(0)).sum(column)
        end

        def number_of_schools(fuel, _metric)
          model(fuel).count
        end

        def enough_data?(_fuel, _metric, number_of_schools)
          number_of_schools.positive?
        end

        def model(fuel)
          { gas: Comparison::AnnualChangeInGasOutOfHoursUse,
            electricity: Comparison::AnnualChangeInElectricityOutOfHoursUse }[fuel]
            .where(school: @impact_report.visible_schools)
        end

        def column(model, metric)
          model.arel_table[[:out_of_hours, metric == :gbp ? :gbpcurrent : metric].join('_')]
        end
      end
    end
  end
end
