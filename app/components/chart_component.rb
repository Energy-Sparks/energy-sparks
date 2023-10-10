# frozen_string_literal: true

class ChartComponent < ViewComponent::Base
  renders_one :title
  renders_one :subtitle
  renders_one :header
  renders_one :footer

  attr_reader :school, :chart_type, :analysis_controls, :no_zoom, :axis_controls, :html_class, :fuel_type

  include ChartHelper

  def initialize(chart_type:, school:, chart_config: nil, analysis_controls: true, no_zoom: true, axis_controls: true, html_class: 'analysis-chart', fuel_type: nil)
    @chart_type = chart_type
    @school = school
    @chart_config = chart_config
    @analysis_controls = analysis_controls
    @no_zoom = no_zoom
    @axis_controls = axis_controls
    @html_class = html_class
    @fuel_type = fuel_type
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

  def chart_tag(school, chart_type, wrap: true, show_advice: false, no_zoom: false, html_class: 'analysis-chart', autoload_chart: true, fuel_type: nil)
    chart_config[:no_advice] = !show_advice
    chart_config[:no_zoom] = no_zoom
    chart_container = content_tag(
      :div,
      '',
      id: chart_id,
      class: html_class,
      data: {
        autoload_chart: autoload_chart,
        chart_config: chart_config.merge(
          type: chart_type,
          annotations: fuel_type ? school_annotations_path(school, fuel_type: fuel_type) : [],
          jsonUrl: school_chart_path(school, format: :json),
          transformations: []
        )
      }
    )
    chart_container += "<div id='chart-error' class='d-none'>#{I18n.t('chart_data_values.standard_error_message')}</div>".html_safe
    if wrap
      content_tag :div, chart_container, id: "chart_wrapper_#{chart_type}", class: 'chart-wrapper'
    else
      chart_container
    end
  end

  private

  def chart_id
    chart_config[:mpan_mprn].present? ? "chart_#{chart_type}_#{chart_config[:mpan_mprn]}" : "chart_#{chart_type}"
  end
end
