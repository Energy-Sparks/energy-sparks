# frozen_string_literal: true

module SchoolGroups
  module ImpactReport
    class Generator
      class AnnualSaving < Base
        METRIC_CATEGORY = :energy_efficiency
        METRICS = %i[annual_saving].freeze
        FUEL_TYPES = %i[electricity gas].freeze
        UNITS = %i[gbp co2 kwh].freeze

        private

        def value(metric) = sum(metric)

        def number_of_schools(metric) = savings(metric).count

        def enough_data?(number_of_schools) = number_of_schools.positive?

        def savings(metric)
          model = if metric[:fuel_type] == :gas
                    Comparison::ChangeInGasSinceLastYear
                  else
                    Comparison::ChangeInElectricitySinceLastYear
                  end
          model.where(school: visible_schools)
               .where(column(model, metric[:unit], :current).lt(column(model, metric[:unit], :previous)))
        end

        def column(model, unit, type) = model.arel_table["#{type}_year_#{unit}"]

        def sum(metric)
          scope = savings(metric)
          scope.sum(column(scope, metric[:unit], :previous) - column(scope, metric[:unit], :current))
        end
      end
    end
  end
end
