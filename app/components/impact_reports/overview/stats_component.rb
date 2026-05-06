# frozen_string_literal: true

module ImpactReports
  module Overview
    class StatsComponent < ImpactReports::BaseComponent # rubocop:disable ViewComponent/PreferComposition
      def show_enrolling?
        run.overview(:enrolling_schools).value > run.overview(:enrolled_schools).value
      end
    end
  end
end
