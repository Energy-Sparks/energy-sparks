module Comparisons
  class ElectricityConsumptionDuringHolidayController < BaseController
    private

    def title_key
      'analytics.benchmarking.chart_table_config.electricity_consumption_during_holiday'
    end

    def load_data
      Comparison::ElectricityConsumptionDuringHoliday.where(school: @schools).order(holiday_projected_usage_gbp: :desc)
    end

    def create_charts(results)
      chart_data = {}

      # Some charts also set x_max_value to 100 if there are metric values > 100
      # Removes issues with schools with large % changes breaking the charts
      #
      # This could be done by clipping values to 100.0 if the metric has a
      # unit of percentage/relative_percent
      results.each do |result|
        metric = result.holiday_projected_usage_gbp
        next if metric.nil? || metric.nan? || metric.infinite?

        chart_data[result.school] = metric
      end

      series_name = I18n.t('analytics.benchmarking.configuration.column_headings.projected_usage_by_end_of_holiday')

      [{
        id: :electricity_consumption_during_holiday,
        x_axis: chart_data.keys.map(&:name),
        x_data: { series_name => chart_data.values },
        y_axis_label: I18n.t('chart_configuration.y_axis_label_name.£')
      }]
    end
  end
end
