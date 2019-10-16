require 'mustache'

class SchoolTemplate < Mustache
  include ChartHelper
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TagHelper

  def initialize(school)
    @school = school
  end

  def chart(chart_config)
    chart_type, y_axis_unit = chart_config.split('|')
    chart_config = {}
    chart_config['y-axis-units'] = y_axis_unit if y_axis_unit.present?
    chart_tag(@school, chart_type, chart_config: chart_config, show_advice: false, html_class: 'embedded-chart')
  end
end
