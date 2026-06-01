# frozen_string_literal: true

module SchoolGroups
  class ImpactReport
    class Generator
      class Overview < Base
        private

        def metric_names = ::ImpactReport::Metric::OVERVIEW_METRICS.map { |metric| [nil, metric, nil] }

        def metric_category = :overview

        def value(_fuel_type, metric_type, _unit) = @impact_report.overview.public_send(metric_type)
      end
    end
  end
end
