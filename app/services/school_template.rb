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
    chart_config['y_axis_units'] = (y_axis_unit || '£')

    ret = "<div id=\"chart_wrapper_#{chart_type}\" class=\"chart-wrapper\">"
    ret += ApplicationController.render(
      partial: 'shared/analysis_controls',
      locals: { chart_type: chart_type, axis_controls: true, analysis_controls: true }
    )
    ret += chart_tag(@school, chart_type, chart_config: chart_config, wrap: false, show_advice: false, html_class: 'analysis-chart embedded-chart')
    ret += "</div>"
    ret
  end
end
