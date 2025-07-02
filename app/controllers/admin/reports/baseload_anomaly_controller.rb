# frozen_string_literal: true

module Admin
  module Reports
    class BaseloadAnomalyController < BaseMeterReportsController
      private

      def results
        results = Report::BaseloadAnomaly.all.with_meter_school_and_group
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
                     ->(row) { row.reading_date }),
          Column.new(:previous_baseload,
                     ->(row) {  FormatEnergyUnit.format(:kw, row.previous_day_baseload.to_f, :html, false, true, :benchmark) },
                     ->(row) {  FormatEnergyUnit.format(:kw, row.previous_day_baseload.to_f, :text, false, true, :benchmark) }),
          Column.new(:baseload,
                     ->(row) {  FormatEnergyUnit.format(:kw, row.today_baseload.to_f, :html, false, true, :benchmark) },
                     ->(row) {  FormatEnergyUnit.format(:kw, row.today_baseload.to_f, :text, false, true, :benchmark) }),
          Column.new(:chart,
                     ->(row) { analysis_school_advice_baseload_url(row.meter.school) },
                     ->(row) { link_to('Chart', analysis_school_advice_baseload_path(row.meter.school))},
                     html_data: { sortable: false })
        ]
      end

      def frequency
        :daily
      end

      def path
        'admin_reports_baseload_anomaly_index_path'
      end

      def description
        'Shows sudden changes in baseload for active electricity meters over the last 30 days.'
      end

      def title
        'Baseload anomalies'
      end
    end
  end
end
