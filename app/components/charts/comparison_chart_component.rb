# frozen_string_literal: true

# For displaying stacked bar charts on the school comparison reports
# Data is provided inline on the page
module Charts
  class ComparisonChartComponent < ApplicationComponent
    renders_one :title
    renders_one :subtitle
    renders_one :introduction

    def initialize(x_axis:, x_data:, y_axis_label:, x_min_value: nil, x_max_value: nil, **_kwargs)
      super
      @x_axis = x_axis
      @x_data = x_data
      @y_axis_label = y_axis_label
      @x_min_value = x_min_value
      @x_max_value = x_max_value
    end

    def height
      number_of_records = @x_axis.size
      [30 * number_of_records, 700].max
    end

    def chart_json
      output = ChartDataValues.new(chart_config, @id).process
      formatted_json_data = ChartDataValues.as_chart_json(output)

      {
        type: @id,
        no_advice: true,
        no_zoom: true,
        transformations: [],
        jsonData: formatted_json_data
      }.to_json
    end

    def render?
      @x_data.any?
    end

    private

    def chart_config
      {
        x_axis: @x_axis,
        x_data: @x_data,
        y_axis_label: @y_axis_label,
        x_min_value: @x_min_value,
        x_max_value: @x_max_value,
        chart1_type: :bar,
        chart1_subtype: :stacked
      }
    end
  end
end
