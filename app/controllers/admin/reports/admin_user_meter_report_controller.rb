# frozen_string_literal: true

module Admin
  module Reports
    class AdminUserMeterReportController < BaseImportReportsController
      private

      def description
        'List of meters for individual school admins based on the associated school groups'
      end

      def title
        'Meters for admin user'
      end

      def results
        admin_user = params[:user].present? ? User.admin.find(params[:user]) : User.admin.first
        results = Meter.active.joins(:school).includes(:school, { school: :school_group }).where(schools: { school_groups: { default_issues_admin_user: admin_user } })
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
