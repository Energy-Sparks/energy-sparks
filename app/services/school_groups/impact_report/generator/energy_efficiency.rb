# frozen_string_literal: true

module SchoolGroups
  class ImpactReport
    class Generator
      class EnergyEfficiency < Base
        METRICS = %i[gbp co2 kwh].freeze

        private

        def metric_category
          :energy_efficiency
        end

        def metric_names
          %i[electricity gas].flat_map { |fuel| METRICS.map { |type| [fuel, type] } }
        end

        def value(fuel, metric)
          sum(fuel, metric)
        end

        def number_of_schools(fuel, metric)
          savings(fuel, metric).count
        end

        def enough_data?(_fuel, _metric, number_of_schools)
          number_of_schools.positive?
        end

        def savings(fuel, metric)
          model = if fuel == :gas
                    Comparison::ChangeInGasSinceLastYear
                  else
                    Comparison::ChangeInElectricitySinceLastYear
                  end
          model.where(school: @impact_report.visible_schools)
               .where(column(model, metric, :current).lt(column(model, metric, :previous)))
        end

        def column(model, metric, type)
          model.arel_table["#{type}_year_#{metric}"]
        end

        def sum(fuel, metric)
          scope = savings(fuel, metric)
          scope.sum(column(scope, metric, :previous) - column(scope, metric, :current))
        end
      end
    end
  end
end
