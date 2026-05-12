# frozen_string_literal: true

module ImpactReports
  module Engagement
    class MetricsComponent < ImpactReports::BaseComponent # rubocop:disable ViewComponent/PreferComposition
      def initialize(**)
        super
        raise_unless_run
      end

      def displayable
        @displayable ||= ImpactReport::Metric.metrics(:engagement)
                                             .select { |metric| engagement(metric)&.nonzero? }.compact
      end
    end
  end
end
