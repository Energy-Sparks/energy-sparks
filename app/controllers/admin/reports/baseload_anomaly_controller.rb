# frozen_string_literal: true

module Admin
  module Reports
    class BaseloadAnomalyController < AdminController
      include Columns
      include ActionView::Helpers::UrlHelper
      include ApplicationHelper

      def index
        @anomalies = Report::BaseloadAnomaly.all.with_meter_school_and_group.default_order
        @columns = [
          Column.new(:school_group,
                     ->(anomaly) { anomaly.meter.school&.school_group&.name },
                     ->(anomaly, csv) { csv && link_to(csv, school_group_path(anomaly.meter.school&.school_group)) }),
          Column.new(:admin,
                     ->(anomaly) { anomaly.meter.school&.school_group&.default_issues_admin_user&.name }),
          Column.new(:school,
                     ->(anomaly) { anomaly.meter.school.name },
                     ->(anomaly, csv) { link_to(csv, school_path(anomaly.meter.school)) }),
          Column.new(:meter,
                     ->(anomaly) { anomaly.meter.mpan_mprn },
                     ->(anomaly, csv) { link_to(csv, school_meter_path(anomaly.meter.school, anomaly.meter)) }),
          Column.new(:meter_name,
                     ->(anomaly) { anomaly.meter&.name }),
          Column.new(:reading_date,
                     ->(anomaly) { anomaly.reading_date }),
          Column.new(:previous_baseload,
                     ->(anomaly) {  FormatEnergyUnit.format(:kw, anomaly.previous_day_baseload.to_f, :html, false, true, :benchmark) },
                     ->(anomaly) {  FormatEnergyUnit.format(:kw, anomaly.previous_day_baseload.to_f, :text, false, true, :benchmark) }),
          Column.new(:baseload,
                     ->(anomaly) {  FormatEnergyUnit.format(:kw, anomaly.today_baseload.to_f, :html, false, true, :benchmark) },
                     ->(anomaly) {  FormatEnergyUnit.format(:kw, anomaly.today_baseload.to_f, :text, false, true, :benchmark) }),
          Column.new(:chart,
                     ->(anomaly) { analysis_school_advice_baseload_url(anomaly.meter.school) },
                     ->(anomaly) { link_to('Chart', analysis_school_advice_baseload_path(anomaly.meter.school))},
                     html_data: { sortable: false })
        ]
        respond_to do |format|
          format.html
          format.csv do
            send_data(csv_report(@columns, @anomalies),
                      filename: EnergySparks::Filenames.csv('baseload-anomalies'))
          end
        end
      end
    end
  end
end
