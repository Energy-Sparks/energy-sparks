# frozen_string_literal: true

module Admin
  module Reports
    class BaseloadAnomalyController < BaseAnomalyReportController
      private

      def results
        results = Report::BaseloadAnomaly.all.with_meter_school_and_group
        filter_results(results)
      end

      def columns
        super + [
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

      def description
        'Shows sudden changes in baseload for active electricity meters over the last 30 days.'
      end

      def title
        'Baseload anomalies'
      end
    end
  end
end
