# frozen_string_literal: true

module Admin
  module Reports
    class ManualReadsController < BaseMeterReportsController
      private

      def columns
        super + [
          Column.new(:meter_type,
                     ->(meter) { meter.meter_type.to_s }),
          Column.new(:data_source,
                     ->(meter) { meter.data_source&.name }),
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

      def results
        results = Meter.active.where(manual_reads: true).with_school_and_group
        results = results.for_school_group(SchoolGroup.find(params[:school_group])) if params[:school_group].present?
        results = results.for_admin(User.admin.find(params[:user])) if params[:user].present?
        results
      end

      def description
        'List of meters configured as needing manual reads'
      end

      def title
        'Manually read meters'
      end
    end
  end
end
