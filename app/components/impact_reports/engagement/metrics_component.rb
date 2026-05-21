# frozen_string_literal: true

module ImpactReports
  module Engagement
    class MetricsComponent < ImpactReports::MetricsBaseComponent # rubocop:disable ViewComponent/PreferComposition
      def displayable
        @displayable ||= ImpactReport::Metric.metrics(:engagement)
                                             .select { |metric| engagement(metric)&.nonzero? }.compact
      end
    end
  end
end
