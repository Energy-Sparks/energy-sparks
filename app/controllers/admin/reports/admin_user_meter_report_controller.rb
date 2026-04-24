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
        default_issues_admin_user = User.admin.find_by(id: params[:admin]) || User.admin.first
        Meter.active
             .joins(:school)
             .includes(:school, { school: :school_group })
             .where(schools: { school_groups: { default_issues_admin_user: } })
             .then { |scope| filter_by_meter_type(scope) }
             .then { |scope| filter_by_school_group(scope) }
      end

      def filter_by_meter_type(scope)
        params[:meter_type].present? ? scope.where(meter_type: params[:meter_type]) : scope
      end

      def filter_by_school_group(scope)
        params[:school_group].present? ? scope.where(schools: { school_group_id: params[:school_group] }) : scope
      end

      def container_class
        'container-fluid'
      end
    end
  end
end
