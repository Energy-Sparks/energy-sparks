# frozen_string_literal: true

# For displaying stacked bar charts on the school comparison reports
class ComparisonChartComponent < ViewComponent::Base
  renders_one :title
  renders_one :subtitle
  renders_one :introduction

  attr_reader :id

  def initialize(id:, x_axis:, x_data:, y_axis_label:)
    @id = id
    @x_axis = x_axis
    @x_data = x_data
    @y_axis_label = y_axis_label
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

  private

  def chart_config
    {
      x_axis: @x_axis,
      x_data: @x_data,
      y_axis_label: @y_axis_label,
      chart1_type: :bar,
      chart1_subtype: :stacked
    }
  end
end
