module Charts
  # Service for producing data structured suitable for use via the ComparisonChartComponent or ChartComponent
  class ComparisonChartData
    def initialize(results,
                   column_heading_keys: 'analytics.benchmarking.configuration.column_headings',
                   y_axis_keys: 'chart_configuration.y_axis_label_name',
                   x_min_value: nil,
                   x_max_value: nil)
      @results = results
      @column_heading_keys = column_heading_keys
      @y_axis_keys = y_axis_keys
      @min_max_values = { x_min_value:, x_max_value: }.compact
    end

    def create_chart(metric_to_translation_key, multiplier, y_axis_label)
      chart_data = {}
      @results.each do |result|
        result.slice(*metric_to_translation_key.keys).each do |metric, value|
          value = value_or_nil(value)
          # for a percentage metric we'd multiply * 100.0
          # for converting from kW to W 1000.0
          value *= multiplier unless value.nil? || multiplier.nil?
          (chart_data[metric] ||= []) << value
        end
      end

      chart_data.transform_keys! { |key| column_heading(metric_to_translation_key[key.to_sym]) }
      chart_hash(school_names, chart_data, y_axis_label)
    end

    def create_calculated_chart(lambda, series_name, y_axis_label)
      values = @results.map { |result| value_or_nil(lambda.call(result)) }
      chart_hash(school_names, { column_heading(series_name) => values }, y_axis_label)
    end

    private

    def school_names
      @results.map { |result| result.school.name }
    end

    def chart_hash(schools, chart_data, y_axis_label)
      { id: :comparison,
        x_axis: schools,
        x_data: chart_data, # x is the vertical axis by default for stacked charts in Highcharts
        y_axis_label: I18n.t("#{@y_axis_keys}.#{y_axis_label}") }.merge(@min_max_values)
    end

    def column_heading(series_name)
      I18n.t("#{@column_heading_keys}.#{series_name}")
    end

    def value_or_nil(value)
      return nil if value.nil? || value.respond_to?(:nan?) && (value.nan? || value.infinite?)
      value
    end
  end
end
