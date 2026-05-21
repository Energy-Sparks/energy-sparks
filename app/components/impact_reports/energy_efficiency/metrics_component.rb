# frozen_string_literal: true

module ImpactReports
  module EnergyEfficiency
    class MetricsComponent < ImpactReports::MetricsBaseComponent # rubocop:disable ViewComponent/PreferComposition
      def max
        4
      end

      def displayable
        run.energy_efficiency.take(max)
      end
    end
  end
end
