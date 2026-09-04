# frozen_string_literal: true

module Admin
  module Reports
    class LimitedDataController < BaseImportReportsController
      private

      def description = 'List of active meters for which we have less than 7 days validated readings'

      def title = 'Meters with limited data'

      def results
        filter_results(Meter.active
                       .joins(:amr_validated_readings, school: :school_group)
                       .group('meters.id', 'schools.id')
                       .having('COUNT(DISTINCT amr_validated_readings.reading_date) < 7')
                       .where(schools: { active: true }))
      end
    end
  end
end
