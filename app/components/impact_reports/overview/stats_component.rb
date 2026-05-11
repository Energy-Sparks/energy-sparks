# frozen_string_literal: true

module ImpactReports
  module Overview
    class StatsComponent < ImpactReports::BaseComponent # rubocop:disable ViewComponent/PreferComposition
      def show_enrolling?
        run.overview(:enrolling_schools).displayable? && run.overview(:enrolling_schools).value.to_i.positive?
      end

      def show_enrolled?
        !show_enrolling? &&
          run.overview(:enrolled_schools).displayable? && overview(:enrolled_schools).value.to_i.positive?
      end

      def show_enrollment?
        show_enrolling? || show_enrolled?
      end

      def cols
        %i[visible_schools users pupils]
          .map { |k| overview(k).displayable? }
          .append(show_enrollment?)
          .count(true)
      end
    end
  end
end
