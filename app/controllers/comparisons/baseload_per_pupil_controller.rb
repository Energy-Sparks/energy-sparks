module Comparisons
  class BaseloadPerPupilController < BaseController
    def index
      @result = Comparison::ReportService.new(definition: definition).perform
      @chart = chart_configuration(@result)
    end

    private

    def definition
      Comparison::ReportDefinition.new(
        report_key: :baseload_per_pupil,
        advice_page: AdvicePage.find_by_key(:baseload),
        schools: @schools,
        metric_type_keys: [:one_year_baseload_per_pupil_kw, :average_baseload_last_year_gbp, :average_baseload_last_year_kw, :annual_baseload_percent, :one_year_saving_versus_exemplar_gbp, :electricity_economic_tariff_changed_this_year],
        order_key: :one_year_baseload_per_pupil_kw,
        alert_types: AlertType.where(class_name: %w[AlertElectricityBaseloadVersusBenchmark AlertAdditionalPrioritisationData]),
        fuel_types: :electricity,
      )
    end

    def chart_configuration(result)
      series_name = I18n.t('analytics.benchmarking.configuration.column_headings.baseload_per_pupil_w')
      chart_data = {}

      # Some charts also set x_max_value to 100 if there are metric values > 100
      # Removes issues with schools with large % changes breaking the charts
      #
      # This could be done by clipping values to 100.0 if the metric has a
      # unit of percentage/relative_percent
      result.schools.each do |school|
        metric = result.metric(school, :one_year_baseload_per_pupil_kw)
        next if metric.nil? || metric.value.nil? || metric.value.nan? || metric.value.infinite?
        # for a percentage metric we'd multiply * 100.0
        # here we're converting from kW to W
        chart_data[school] = metric.value * 1000.0
      end

      # TODO need to improve chart display so it has a proper title and subtitle like our other charts,
      # that will be handled in a new chart component or view
      #
      # Other improvements: disable legend clicking, ensuring colour coding matches what we use elsewhere?
      {
        title: nil,
        x_axis: chart_data.keys.map(&:name),
        x_axis_ranges: nil,
        x_data: { series_name => chart_data.values },
        y_axis_label: I18n.t('chart_configuration.y_axis_label_name.kw'),
        chart1_type: :bar,
        chart1_subtype: :stacked,
        config_name: :baseload_per_pupil
      }
    end
  end
end
