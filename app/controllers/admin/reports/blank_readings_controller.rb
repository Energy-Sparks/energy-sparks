# frozen_string_literal: true

module Admin
  module Reports
    class BlankReadingsController < BaseImportReportsController
      private

      def results
        results = ImportNotifier.new.meters_with_blank_data
        #        results = results.where(meter_type: params[:meter_type]) if params[:meter_type].present?
        #        results = results.where(schools: { school_groups: { default_issues_admin_user: User.admin.find(params[:user]) } }) if params[:user].present?
        #        results = results.where(schools: { school_group: SchoolGroup.find(params[:school_group]) }) if params[:school_group].present?
        results
      end

      def path
        'admin_reports_blank_readings_path'
      end

      def description
        'Meters where we have received one or more days of entirely blank data in the last 24 hours'
      end

      def title
        'Meters with recent blank readings'
      end
    end
  end
end
