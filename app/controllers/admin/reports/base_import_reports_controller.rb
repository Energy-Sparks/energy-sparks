# frozen_string_literal: true

module Admin
  module Reports
    # Base class for a set of reports that present basic information
    # about recent import issues. The reports have a common structure that
    # is defined here. Subclasses should define queries that return the
    # required data
    class BaseImportReportsController < BaseMeterReportsController
      private

      def columns # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
        super + [
          Column.new(:meter_type,
                     ->(meter) { meter.meter_type.to_s },
                     lambda { |meter|
                       render_to_string(Elements::IconComponent.new(fuel_type: meter.meter_type), layout: false)
                     }),
          Column.new(:meter_system,
                     ->(meter) { meter.t_meter_system }),
          Column.new(:supplier,
                     ->(meter) { meter.supplier&.name },
                     ->(meter, csv) { csv && link_to(csv, admin_supplier_path(meter.supplier)) }),
          Column.new(:data_source,
                     ->(meter) { meter.data_source&.name },
                     ->(meter, csv) { csv && link_to(csv, admin_data_source_path(meter.data_source)) }),
          Column.new(:procurement_route,
                     ->(meter) { meter.procurement_route&.organisation_name },
                     ->(meter, csv) { csv && link_to(csv, admin_procurement_route_path(meter.procurement_route)) }),
          Column.new(:admin_meter_status,
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
          Column.new(:issues, ->(meter) { meter.issues.issue.count }, display: :csv),
          Column.new(:notes, ->(meter) { meter.issues.note.count }, display: :csv)
        ]
      end

      def filter_results(results)
        # results = results.preload(:school,
        #                           { school: { school_group: :default_issues_admin_user } },
        #                           :supplier,
        #                           :data_source,
        #                           :procurement_route,
        #                           :admin_meter_status)
        results = filter_by_meter_type(results)
        results = filter_by_admin(results)
        results = filter_by_school_group(results)
        filter_by_admin_meter_status(results)
      end

      def filter_by_meter_type(results)
        apply_filter(results, :meter_type) do |results, meter_type|
          results.where(meter_type:)
        end
      end

      def filter_by_admin(results)
        apply_filter(results, :admin) do |results, admin_id|
          results.where(schools: { school_groups: { default_issues_admin_user: User.admin.find(admin_id) } })
        end
      end

      def filter_by_school_group(results)
        apply_filter(results, :school_group) do |results, school_group_id|
          results.where(schools: { school_group: SchoolGroup.find(school_group_id) })
        end
      end

      def filter_by_admin_meter_status(results)
        apply_filter(results, :admin_meter_status) do |results, status_id|
          results.where(admin_meter_status: AdminMeterStatus.find(status_id))
        end
      end

      def apply_filter(results, key)
        params[key].present? ? yield(results, params[key]) : results
      end

      def container_class = 'container-fluid'
    end
  end
end
