# frozen_string_literal: true

module ImpactReports
  module Overview
    class StatsComponent < ImpactReports::BaseComponent
      def show_enrolling?
        @impact_report.overview.enrolling_schools > @impact_report.overview.enrolled_schools
      end
    end
  end
end
