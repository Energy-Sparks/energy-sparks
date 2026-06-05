# frozen_string_literal: true

module ImpactReports
  module PotentialSavings
    class MetricsComponent < ImpactReports::MetricsBaseComponent # rubocop:disable ViewComponent/PreferComposition
      def initialize(max: 2, **)
        super(**)
        @max = max
      end

      def displayable
        metrics = run.potential_savings
        @max ? metrics.take(@max) : metrics
      end
    end
  end
end
