# frozen_string_literal: true

module SchoolGroups
  class ImpactReport
    class Generator
      class Targets < Base
        METRICS = %i[targets].freeze

        private

        def value(fuel, _metric, _unit) = model(fuel).where('previous_to_current_year_change < 0').count

        def number_of_schools(fuel, _metric, _unit) = model(fuel).count

        def enough_data?(number_of_schools) = number_of_schools.positive?

        def model(fuel)
          { gas: Comparison::GasTargets,
            electricity: Comparison::ElectricityTargets }[fuel].where(school: @impact_report.visible_schools).with_data
        end
      end
    end
  end
end
