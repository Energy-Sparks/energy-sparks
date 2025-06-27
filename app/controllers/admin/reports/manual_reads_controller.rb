# frozen_string_literal: true

module Admin
  module Reports
    class ManualReadsController < MeterDataReportsController
      private

      def columns
        [
          Column.new(:school_group,
                     ->(meter) { meter.school&.school_group&.name },
                     ->(meter, csv) { csv && link_to(csv, school_group_path(meter.school&.school_group)) }),
          Column.new(:admin,
                     ->(meter) { meter.school&.school_group&.default_issues_admin_user&.name }),
          Column.new(:school,
                     ->(meter) { meter.school.name },
                     ->(meter, csv) { link_to(csv, school_path(meter.school)) }),
          Column.new(:meter,
                     ->(meter) { meter.mpan_mprn },
                     ->(meter, csv) { link_to(csv, school_meter_path(meter.school, meter)) }),
          Column.new(:meter_name,
                     ->(meter) { meter&.name }),
          Column.new(:meter_type,
                     ->(meter) { meter.meter_type.to_s }),
          Column.new(:data_source,
                     ->(meter) { meter.data_source&.name }),
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

      def frequency
        :on_demand
      end

      def results
        Meter.active.where(manual_reads: true)
      end

      def path
        'admin_reports_manual_reads_path'
      end

      def description
        'List of meters configured as needing manual reads'
      end

      def title
        'Manual read meters'
      end
    end
  end
end
