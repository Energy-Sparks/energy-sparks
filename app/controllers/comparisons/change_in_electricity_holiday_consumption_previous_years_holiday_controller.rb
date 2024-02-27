# frozen_string_literal: true

module Comparisons
  class ChangeInElectricityHolidayConsumptionPreviousYearsHolidayController < BaseController
    private

    def title_key
      'analytics.benchmarking.chart_table_config.change_in_electricity_holiday_consumption_previous_years_holiday'
    end

    def advice_page_key
      :electricity_intraday
    end

    def load_data
      Comparison::ChangeInElectricityHolidayConsumptionPreviousYearsHoliday
        .where(school: @schools).order(difference_percent: :desc)
    end

    def create_charts(results)
      chart_data = {}

      # Some charts also set x_max_value to 100 if there are metric values > 100
      # Removes issues with schools with large % changes breaking the charts
      #
      # This could be done by clipping values to 100.0 if the metric has a
      # unit of percentage/relative_percent
      results.each do |result|
        metric = result.difference_percent
        next if metric.nil? || metric.nan? || metric.infinite?

        # for a percentage metric we'd multiply * 100.0
        chart_data[result.school] = metric * 100.0
      end

      series_name = I18n.t('analytics.benchmarking.configuration.column_headings.change_pct')

      [{
        id: :electricity_peak_kw_per_pupil,
        x_axis: chart_data.keys.map(&:name),
        x_data: { series_name => chart_data.values },
        y_axis_label: I18n.t('chart_configuration.y_axis_label_name.percent')
      }]
    end
  end
end
