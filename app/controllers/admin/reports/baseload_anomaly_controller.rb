# frozen_string_literal: true

module Admin
  module Reports
    class BaseloadAnomalyController < MeterDataReportsController
      def index
        @rows = Report::BaseloadAnomaly.all.with_meter_school_and_group
        @rows = @rows.for_school_group(SchoolGroup.find(params[:school_group])) if params[:school_group].present?
        @rows = @rows.for_admin(User.admin.find(params[:user])) if params[:user].present?
        @rows = @rows.default_order

        respond_to do |format|
          format.html
          format.csv do
            send_data(csv_report(@columns, @rows),
                      filename: EnergySparks::Filenames.csv('baseload-anomalies'))
          end
        end
      end

      private

      def columns
        super + [
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
