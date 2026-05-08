# frozen_string_literal: true

module SchoolGroups
  class ImpactReport
    class Generator
      class EnergyEfficiency < Base
        METRICS = %i[gbp co2 kwh].freeze

        def initialize(*)
          super
          @number_of_schools = {}
        end

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

        def enough_data?(fuel, metric)
          savings(fuel, metric).any?
        end

        def savings(fuel, metric)
          scope = if fuel == :gas
                    Comparison::ChangeInGasSinceLastYear
                  else
                    Comparison::ChangeInElectricitySinceLastYear
                  end
          scope.where("current_year_#{metric} < previous_year_#{metric}")
        end

        def sum(fuel, metric)
          savings(fuel, metric).sum("previous_year_#{metric} - current_year_#{metric}")
        end
      end
    end
  end
end
