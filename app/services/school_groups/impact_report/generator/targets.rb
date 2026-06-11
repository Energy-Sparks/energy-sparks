# frozen_string_literal: true

module SchoolGroups
  module ImpactReport
    class Generator
      class Targets < Base
        METRIC_CATEGORY = :energy_efficiency
        METRICS = %i[targets].freeze
        FUEL_TYPES = %i[electricity gas].freeze

        private

        def value(metric) = model(metric[:fuel_type]).where('previous_to_current_year_change < 0').count

        def number_of_schools(metric) = model(metric[:fuel_type]).count

        def enough_data?(number_of_schools) = number_of_schools.positive?

        def model(fuel)
          { gas: Comparison::GasTargets,
            electricity: Comparison::ElectricityTargets }[fuel].where(school: visible_schools).with_data
        end
      end
    end
  end
end
