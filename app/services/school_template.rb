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

    ApplicationController.render(
      partial: 'shared/chart_with_controls',
      locals: { school: @school, chart_type: chart_type, chart_config: chart_config }
    )
  end
end
