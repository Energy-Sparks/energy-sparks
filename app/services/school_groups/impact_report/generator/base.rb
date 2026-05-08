module SchoolGroups
  class ImpactReport
    class Generator
      class Base
        def initialize(impact_report)
          @impact_report = impact_report
        end

        def metrics
          metric_names.map do |fuel_type, metric_type|
            { enough_data: enough_data?(fuel_type, metric_type),
              fuel_type:,
              metric_category:,
              metric_type:,
              number_of_schools: number_of_schools(metric_type),
              value: value(fuel_type, metric_type) }
          end
        end

        private

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
