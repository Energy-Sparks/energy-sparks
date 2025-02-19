# frozen_string_literal: true

class ChartComponent < ViewComponent::Base
  include ApplicationHelper

  renders_one :title
  renders_one :subtitle
  renders_one :header
  renders_one :footer

  attr_reader :school, :chart_type, :analysis_controls, :no_zoom, :axis_controls, :html_class, :fuel_type, :autoload_chart

  include ChartHelper

  def initialize(chart_type:, school:, chart_config: nil, analysis_controls: true, no_zoom: true, axis_controls: true,
                 html_class: 'analysis-chart', fuel_type: nil, autoload_chart: true,
                 show_how_have_we_analysed_your_data: true)
    @chart_type = chart_type
    @school = school
    @chart_config = chart_config
    @analysis_controls = analysis_controls
    @no_zoom = no_zoom
    @axis_controls = axis_controls
    @html_class = html_class
    @fuel_type = fuel_type
    @autoload_chart = autoload_chart
    @show_how_have_we_analysed_your_data = show_how_have_we_analysed_your_data
  end

  def chart_config
    @chart_config ||= create_chart_config(@school, @chart_type, export_title: @export_title, export_subtitle: @export_subtitle)
  rescue StandardError
    nil
  end

  def before_render
    @export_title = title.present? ? title.to_s : ''
    @export_subtitle = subtitle.present? ? subtitle.to_s : ''
  end

  def valid_config?
    !chart_config.nil?
  end

  def chart_config_json
    @chart_config_json ||= build_chart_config_to_json
  end

  private

  def build_chart_config_to_json
    chart_config.merge(
      no_zoom: no_zoom,
      type: chart_type,
      annotations: fuel_type ? school_annotations_path(school, fuel_type: fuel_type) : [],
      jsonUrl: school_chart_path(school, format: :json),
      transformations: []
    ).to_json
  end

  def chart_id
    chart_config[:mpan_mprn].present? ? "chart_#{chart_type}_#{@chart_config[:mpan_mprn]}" : "chart_#{chart_type}"
  end
end
