# frozen_string_literal: true

module SchoolGroups
  class ImpactReport
    class Generator
      class AnnualSaving < Base
        UNITS = %i[gbp co2 kwh].freeze
        METRICS = %i[annual_saving].freeze

        private

        def value(fuel, _metric, unit) = sum(fuel, unit)

        def number_of_schools(fuel, _metric, unit) = savings(fuel, unit).count

        def enough_data?(number_of_schools) = number_of_schools.positive?

        def savings(fuel, unit)
          model = if fuel == :gas
                    Comparison::ChangeInGasSinceLastYear
                  else
                    Comparison::ChangeInElectricitySinceLastYear
                  end
          model.where(school: @impact_report.visible_schools)
               .where(column(model, unit, :current).lt(column(model, unit, :previous)))
        end

        def column(model, unit, type) = model.arel_table["#{type}_year_#{unit}"]

        def sum(fuel, unit)
          scope = savings(fuel, unit)
          scope.sum(column(scope, unit, :previous) - column(scope, unit, :current))
        end
      end
    end
  end
end
