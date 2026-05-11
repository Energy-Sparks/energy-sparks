# frozen_string_literal: true

module ImpactReports
  module Overview
    class MetricsComponent < ImpactReports::BaseComponent # rubocop:disable ViewComponent/PreferComposition
      def initialize(**)
        super
        raise_unless_run
      end

      def display_enrolling?
        overview?(:enrolling_schools) && overview(:enrolling_schools).value.to_i.positive?
      end

      def display_enrolled?
        !display_enrolling? &&
          overview?(:enrolled_schools) && overview(:enrolled_schools).value.to_i.positive?
      end

      def display_enrollment?
        display_enrolling? || display_enrolled?
      end

      def cols
        %i[visible_schools users pupils]
          .map { |metric| overview?(metric) }
          .append(display_enrollment?)
          .count(true)
      end
    end
  end
end
