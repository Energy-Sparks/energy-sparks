# frozen_string_literal: true

module Admin
  module Reports
    # Base class for a set of reports that present basic information
    # about recent import issues. The reports have a common structure that
    # is defined here. Subclasses should define queries that return the
    # required data
    class BaseImportReportsController < BaseMeterReportsController
      private

      def columns
        super + [
          Column.new(:meter_type,
                     ->(meter) { meter.meter_type.to_s },
                     ->(meter) { render_to_string(IconComponent.new(fuel_type: meter.meter_type), layout: false) }),
          Column.new(:meter_system,
                     ->(meter) { meter.t_meter_system }),
          Column.new(:data_source,
                     ->(meter) { meter.data_source&.name },
                     ->(meter, csv) { csv && link_to(csv, admin_data_source_path(meter.data_source)) }),
          Column.new(:procurement_route,
                     ->(meter) { meter.procurement_route&.organisation_name },
                     ->(meter, csv) { csv && link_to(csv, admin_procurement_route_path(meter.procurement_route)) }),
          Column.new(:meter_status,
                     ->(meter) { meter.admin_meter_status_label }),
          Column.new(:manual_reads,
                     ->(meter) { meter.manual_reads ? 'Y' : 'N' }),
          Column.new(:last_validated_date,
                     ->(meter) { meter.last_validated_reading&.iso8601 },
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

      def filter_results(results)
        results = results.where(meter_type: params[:meter_type]) if params[:meter_type].present?
        results = results.where(schools: { school_groups: { default_issues_admin_user: User.admin.find(params[:user]) } }) if params[:user].present?
        results = results.where(schools: { school_group: SchoolGroup.find(params[:school_group]) }) if params[:school_group].present?
        results
      end

      def container_class
        'container-fluid'
      end
    end
  end
end
