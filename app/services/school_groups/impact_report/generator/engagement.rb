# frozen_string_literal: true

module SchoolGroups
  class ImpactReport
    class Generator
      class Engagement < Base
        private

        def metric_category = :engagement

        def metric_names = ::ImpactReport::Metric::ENGAGEMENT_METRICS.map { |metric| [nil, metric, nil] }

        def value(_fuel_type, metric_type, _unit) = @impact_report.engagement.public_send(metric_type)
      end
    end
  end
end
