# frozen_string_literal: true

module Admin
  module Reports
    class GasAnomalyController < BaseMeterReportsController
      private

      def results
        results = Report::GasAnomaly.all.with_meter_school_and_group
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
          Column.new(:kwh,
                     ->(row) {  FormatEnergyUnit.format(:kwh, row.today_kwh.to_f, :html, false, true, :benchmark) },
                     ->(row) {  FormatEnergyUnit.format(:kwh, row.today_kwh.to_f, :text, false, true, :benchmark) }),
          Column.new(:previous_kwh,
                      ->(row) {  FormatEnergyUnit.format(:kwh, row.previous_kwh.to_f, :html, false, true, :benchmark) },
                      ->(row) {  FormatEnergyUnit.format(:kwh, row.previous_kwh.to_f, :text, false, true, :benchmark) }),
          Column.new(:temperature,
                     ->(row) {  FormatEnergyUnit.format(:temperature, row.today_temperature.to_f, :html, false, true, :benchmark) },
                     ->(row) {  FormatEnergyUnit.format(:temperature, row.today_temperature.to_f, :text, false, true, :benchmark) }),
          Column.new(:previous_temperature,
                      ->(row) {  FormatEnergyUnit.format(:temperature, row.previous_temperature.to_f, :html, false, true, :benchmark) },
                      ->(row) {  FormatEnergyUnit.format(:temperature, row.previous_temperature.to_f, :text, false, true, :benchmark) }),
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
