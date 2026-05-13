# frozen_string_literal: true

module SchoolGroups
  class ImpactReport
    class Generator
      class Targets < Base
        METRICS = %i[targets].freeze

        private

        def metric_category
          :energy_efficiency
        end

        def value(fuel, _metric)
          model(fuel).where('previous_to_current_year_change < 0').count
        end

        def number_of_schools(fuel, _metric)
          model(fuel).count
        end

        def enough_data?(_fuel, _metric, number_of_schools)
          number_of_schools.positive?
        end

        def model(fuel)
          { gas: Comparison::GasTargets,
            electricity: Comparison::ElectricityTargets }[fuel].where(school: @impact_report.visible_schools).with_data
        end
      end
    end
  end
end
