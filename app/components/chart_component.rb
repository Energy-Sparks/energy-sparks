# frozen_string_literal: true

class ChartComponent < ViewComponent::Base
  renders_one :title
  renders_one :subtitle
  renders_one :header
  renders_one :footer

  attr_reader :school, :chart_type, :analysis_controls, :no_zoom, :axis_controls, :html_class

  include ChartHelper

  def initialize(chart_type:, school:, chart_config: nil, analysis_controls: true, no_zoom: true, axis_controls: true, html_class: 'analysis-chart', export_title: '')
    @chart_type = chart_type
    @school = school
    @chart_config = chart_config
    @analysis_controls = analysis_controls
    @no_zoom = no_zoom
    @axis_controls = axis_controls
    @html_class = html_class
    @export_title = export_title
  end

  def chart_config
    @chart_config ||= create_chart_config(@school, @chart_type, export_title: @export_title)
  rescue StandardError
    nil
  end

  def valid_config?
    !chart_config.nil?
  end
end
