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
        results = Meter.inactive
                       .joins(:school, :amr_data_feed_readings)
                       .where(schools: { active: true })
                       .where(admin_meter_status: AdminMeterStatus.include_in_inactive_meter_report)
                       .where('amr_data_feed_readings.created_at >= ?', Time.zone.today - 30)
        results = results.includes(:school, { school: :school_group })
        results = results.for_admin(User.admin.find(params[:user])) if params[:user].present?
        results = results.where(meter_type: params[:meter_type]) if params[:meter_type].present?
        results = results.where(schools: { school_group: SchoolGroup.find(params[:school_group]) }) if params[:school_group].present?
        results
      end

      def container_class
        'container-fluid'
      end
    end
  end
end
