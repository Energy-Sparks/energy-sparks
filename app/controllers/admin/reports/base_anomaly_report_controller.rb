# frozen_string_literal: true

module Admin
  module Reports
    class BaseAnomalyReportController < BaseMeterReportsController
      private

      def filter_results(results)
        results = results.for_school_group(SchoolGroup.find(params[:school_group])) if params[:school_group].present?
        results = results.for_admin(User.admin.find(params[:user])) if params[:user].present?
        results.default_order
      end

      def columns
        [
          Column.new(:school_group,
                     ->(row) { row.meter.school&.school_group&.name },
                     ->(row, csv) { csv && link_to(csv, school_group_path(row.meter.school&.school_group)) }),
          Column.new(:admin,
                     ->(row) { row.meter.school&.school_group&.default_issues_admin_user&.name }),
          Column.new(:school,
                     ->(row) { row.meter.school.name },
                     ->(row, csv) { link_to(csv, school_path(row.meter.school)) }),
          Column.new(:meter,
                     ->(row) { row.meter.mpan_mprn },
                     ->(row, csv) { link_to(csv, school_meter_path(row.meter.school, row.meter)) }),
          Column.new(:meter_name,
                     ->(row) { row.meter&.name }),
          Column.new(:reading_date,
                     ->(row) { row.reading_date })

        ]
      end
    end
  end
end
