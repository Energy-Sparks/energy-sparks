# frozen_string_literal: true

module ImpactReports
  module PotentialSavings
    class MetricsComponent < ImpactReports::MetricsBaseComponent # rubocop:disable ViewComponent/PreferComposition
      def max
        2
      end

      def displayable
        run.potential_savings.take(max)
      end
    end
  end
end
