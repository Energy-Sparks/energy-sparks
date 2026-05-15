# frozen_string_literal: true

module SchoolGroups
  class ImpactReport
    class Generator
      class Engagement < Base
        private

        def metric_category
          :engagement
        end

        def metric_names
          ::ImpactReport::Metric::ENGAGEMENT_METRICS.map { |metric| [nil, metric] }
        end

        def value(_fuel_type, metric_type)
          @impact_report.engagement.public_send(metric_type)
        end
      end
    end
  end
end
