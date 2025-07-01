# frozen_string_literal: true

module Admin
  module Reports
    class LaggingMetersController < MeterDataReportsController
      private

      def results
        results = ImportNotifier.new.meters_running_behind
        results = results.where(meter_type: params[:meter_type]) if params[:meter_type].present?
        results = results.where(schools: { school_groups: { default_issues_admin_user: User.admin.find(params[:user]) } }) if params[:user].present?
        results = results.where(schools: { school_group: SchoolGroup.find(params[:school_group]) }) if params[:school_group].present?
        results
      end

      def columns
        super + [
          Column.new(:meter_type,
                     ->(meter) { meter.meter_type.to_s }),
          Column.new(:meter_system,
                     ->(meter) { meter.t_meter_system }),
          Column.new(:data_source,
                     ->(meter) { meter.data_source&.name }),
          Column.new(:procurement_route,
                     ->(meter) { meter.procurement_route&.organisation_name }),
          Column.new(:meter_status,
                     ->(meter) { meter.admin_meter_status_label }),
          Column.new(:manual_reads,
                     ->(meter) { meter.manual_reads ? 'Y' : 'N' }),
          Column.new(:last_validated_date,
                     ->(meter) { meter.last_validated_reading&.strftime('%d/%m/%Y') },
                     ->(meter) { nice_dates(meter.last_validated_reading) }),
          Column.new(:'issues_&_notes',
                     nil,
                     ->(meter) { render_to_string(partial: 'admin/issues/modal', locals: { meter: }) },
                     display: :html),
          Column.new(:issues,
                     ->(meter) { meter.issues.issue.count },
                     display: :csv),
          Column.new(:notes,
                    ->(meter) { meter.issues.note.count },
                     display: :csv)
        ]
      end

      def container_class
        'container-fluid'
      end

      def frequency
        :on_demand
      end

      def path
        'admin_reports_lagging_meters_path'
      end

      def description
        'List of meters that have stale data'
      end

      def title
        'Lagging meters'
      end
    end
  end
end
