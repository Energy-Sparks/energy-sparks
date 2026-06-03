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
        params[:active] ||= 'true'
        unless params.key?(:school_group) || params.key?(:admin)
          params[:admin] = current_user.id
          return nil
        end
        filtered_meters
      end

      def columns
        super.insert(7, Column.new(:active, ->(meter) { meter.active }))
      end

      def filtered_meters
        Meter.then { |scope| filter_by_active(scope) }
             .joins(:school)
             .includes(:school, { school: :school_group })
             .then { |scope| filter_by_admin(scope) }
             .then { |scope| filter_by_meter_type(scope) }
             .then { |scope| filter_by_school_group(scope) }
      end

      def filter_by_admin(scope)
        filter(scope, params[:admin]) { scope.where(school_groups: { default_issues_admin_user_id: params[:admin] }) }
      end

      def filter_by_meter_type(scope)
        filter(scope, params[:meter_type]) { scope.where(meter_type: params[:meter_type]) }
      end

      def filter_by_school_group(scope)
        filter(scope, params[:school_group]) { scope.where(schools: { school_group_id: params[:school_group] }) }
      end

      def filter_by_active(scope)
        return scope if params[:active] == 'all'

        filter(scope, params[:active]) { scope.where(active: params[:active]) }
      end

      def filter(scope, condition)
        condition.present? ? yield : scope
      end

      def container_class
        'container-fluid'
      end
    end
  end
end
