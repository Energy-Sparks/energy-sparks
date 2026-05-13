# frozen_string_literal: true

module ImpactReports
  module PotentialSavings
    class MetricsComponent < ImpactReports::BaseComponent # rubocop:disable ViewComponent/PreferComposition
      def initialize(**)
        super
        raise_unless_run
      end

      def max
        3
      end

      # NB need to add singular translations to keys for when only one school

      def displayable
        run.potential_savings.take(max)
      end
    end
  end
end
