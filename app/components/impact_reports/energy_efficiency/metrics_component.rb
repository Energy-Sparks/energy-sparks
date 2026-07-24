# frozen_string_literal: true

module ImpactReports
  module EnergyEfficiency
    class MetricsComponent < ImpactReports::MetricsBaseComponent # rubocop:disable ViewComponent/PreferComposition
      def initialize(max: 4, gbp_threshold: nil, **)
        super(**)
        @max = max
        @gbp_threshold = gbp_threshold
      end

      def displayable
        metrics = run.energy_efficiency(**{ gbp_threshold: @gbp_threshold }.compact)
        @max ? metrics.take(@max) : metrics
      end
    end
  end
end
