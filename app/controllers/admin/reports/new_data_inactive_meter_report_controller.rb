# frozen_string_literal: true

module Admin
  module Reports
    class NewDataInactiveMeterReportController < BaseImportReportsController
      private

      def description
        'List of inactive meters for which we have loaded unvalidated readings in the last 30 days'
      end

      def title
        'New data for inactive meters'
      end

      def results
        filter_results(Meter.inactive
                       .joins(:school, :amr_data_feed_readings)
                       .includes(:school, { school: :school_group })
                       .where(schools: { active: true })
                       .where(admin_meter_status: AdminMeterStatus.include_in_inactive_meter_report)
                       .where('amr_data_feed_readings.created_at >= ?', Time.zone.today - 30)
                       .order('amr_data_feed_readings.created_at DESC'))
      end

      def container_class
        'container-fluid'
      end
    end
  end
end
