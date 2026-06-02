# frozen_string_literal: true

module SchoolGroups
  class ImpactReport
    class Generator
      class Overview < Base
        private

        def metric_names
          ::ImpactReport::Metric::OVERVIEW_METRICS.map { |metric| [nil, metric] }
        end

        def metric_category
          :overview
        end

        def value(_fuel_type, metric_type)
          @impact_report.overview.public_send(metric_type)
        end
      end
    end
  end
end
