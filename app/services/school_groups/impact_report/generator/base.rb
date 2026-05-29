# frozen_string_literal: true

module SchoolGroups
  class ImpactReport
    class Generator
      class Base
        def initialize(impact_report)
          @impact_report = impact_report
        end

        def self.metric_type(name)
          name
        end

        def metrics
          metric_names.map do |fuel_type, metric, unit|
            number_of_schools = number_of_schools(fuel_type, metric, unit)
            { enough_data: enough_data?(fuel_type, metric, unit, number_of_schools),
              fuel_type:,
              metric_category:,
              metric_type: self.class.metric_type(metric),
              unit:,
              number_of_schools:,
              value: value(fuel_type, metric, unit) }
          end
        end

        private

        def metric_names
          %i[electricity gas].product(self.class::METRICS, self.class::UNITS)
        end

        def enough_data?(*)
          true
        end

        def number_of_schools(*)
          @impact_report.visible_schools_count
        end
      end
    end
  end
end
