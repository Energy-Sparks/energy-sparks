# frozen_string_literal: true

module ImpactReports
  module Overview
    class MetricsComponent < ImpactReports::MetricsBaseComponent # rubocop:disable ViewComponent/PreferComposition
      def displayable
        @displayable ||= main_metrics.append(enrollment_metrics).compact
      end

      private

      def main_metrics
        %i[visible_schools users pupils].select { |metric| overview(metric)&.available? }
      end

      def enrollment_metrics
        # return the first metric that has a value above zero
        %i[enrolling_schools enrolled_schools].find { |metric| overview(metric)&.nonzero? }
      end
    end
  end
end
