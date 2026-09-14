# frozen_string_literal: true

module Admin
  module Reports
    class StaleDataController < BaseImportReportsController
      private

      def description = 'List of active meters where validated data is more than 30 days old'

      def title = 'Meters with stale data'

      def results
        filter_results(Meter.active
                            .joins(:amr_validated_readings, school: :school_group)
                            .group('meters.id', 'schools.id')
                            .having("MAX(amr_validated_readings.reading_date) < CURRENT_DATE - INTERVAL '30 days'")
                            .where(schools: { active: true }))
      end
    end
  end
end
