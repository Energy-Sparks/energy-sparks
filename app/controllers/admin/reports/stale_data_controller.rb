# frozen_string_literal: true

module Admin
  module Reports
    class StaleDataController < BaseImportReportsController
      private

      def description = 'List of active meters where validated data is more than 30 days old'

      def title = 'Meters with stale data'

      def results
        filter_results(Meter.with_stale_readings(30).joins(school: :school_group))
      end
    end
  end
end
