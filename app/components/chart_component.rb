# frozen_string_literal: true

class ChartComponent < ViewComponent::Base
  renders_one :header
  renders_one :footer

  attr_reader :school, :title, :subtitle, :chart_type, :chart_config, :analysis_controls, :no_zoom, :html_class

  include ChartHelper

  def initialize(chart_type: '', school: nil, title: '', subtitle: '', chart_config: {}, analysis_controls: false, no_zoom: true, html_class: 'analysis-chart')
    @chart_type = chart_type
    @school = school
    @title = title
    @subtitle = subtitle
    @chart_config = chart_config
    @analysis_controls = analysis_controls
    @no_zoom = no_zoom
    @html_class = html_class
  end
end
