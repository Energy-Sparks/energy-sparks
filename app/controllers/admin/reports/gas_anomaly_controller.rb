# frozen_string_literal: true

module Admin
  module Reports
    class GasAnomalyController < BaseAnomalyReportController
      private

      def results
        results = Report::GasAnomaly.all.with_meter_school_and_group
        filter_results(results)
      end

      def columns
        super + [
          Column.new(:kwh,
                     ->(row) {  FormatUnit.format(:kwh, row.today_kwh.to_f, :html, false, true, :benchmark) },
                     ->(row) {  FormatUnit.format(:kwh, row.today_kwh.to_f, :text, false, true, :benchmark) }),
          Column.new(:previous_kwh,
                      ->(row) {  FormatUnit.format(:kwh, row.previous_kwh.to_f, :html, false, true, :benchmark) },
                      ->(row) {  FormatUnit.format(:kwh, row.previous_kwh.to_f, :text, false, true, :benchmark) }),
          Column.new(:temperature,
                     ->(row) {  FormatUnit.format(:temperature, row.today_temperature.to_f, :html, false, true, :benchmark) },
                     ->(row) {  FormatUnit.format(:temperature, row.today_temperature.to_f, :text, false, true, :benchmark) }),
          Column.new(:previous_temperature,
                      ->(row) {  FormatUnit.format(:temperature, row.previous_temperature.to_f, :html, false, true, :benchmark) },
                      ->(row) {  FormatUnit.format(:temperature, row.previous_temperature.to_f, :text, false, true, :benchmark) }),
          Column.new(:period,
                      ->(row) { row.calendar_event_type.title }),
          Column.new(:chart,
                     nil,
                     ->(row) do
                       link_to('Chart', school_usage_path(row.meter.school,
                                          period: :weekly,
                                          supply: :gas,
                                          date: row.reading_date,
                                          compare_to: row.previous_reading_date,
                                          mpxn: row.meter.mpan_mprn
                       ))
                     end,
                     display: :html,
                     html_data: { sortable: false })
        ]
      end

      def container_class
        :container_fluid
      end

      def frequency
        :daily
      end

      def description
        'Gas meters that have unusually high readings compared to recent usage, time of year and temperature.'
      end

      def title
        'Gas usage anomalies'
      end
    end
  end
end
