# frozen_string_literal: true

module ImpactReports
  module Overview
    class MetricsComponent < ImpactReports::BaseComponent # rubocop:disable ViewComponent/PreferComposition
      def initialize(**)
        super
        raise_unless_run
      end

      def displayable
        @displayable ||= main_metrics.append(enrollment_metrics).compact
      end

      private

      def main_metrics
        %i[visible_schools users pupils].select { |metric| overview(metric)&.available? }
      end

      def enrollment_metrics
        %i[enrolling_schools enrolled_schools].find { |metric| overview(metric)&.nonzero? }
      end
    end
  end
end
