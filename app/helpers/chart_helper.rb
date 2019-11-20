module ChartHelper
  def chart_tag(school, chart_type, wrap: true, show_advice: true, no_zoom: false, chart_config: {}, html_class: 'analysis-chart')
    chart_config[:no_advice] = !show_advice
    chart_config[:no_zoom] = no_zoom
    chart_container = content_tag(
      :div,
      '',
      id: "chart_#{chart_type}",
      class: html_class,
      data: {
        chart_config: chart_config.merge(
          type: chart_type,
          annotations: school_annotations_path(school),
          jsonUrl: school_chart_path(school, format: :json),
          transformations: []
        )
      }
    )
    if wrap
      content_tag :div, chart_container, id: "chart_wrapper_#{chart_type}", class: 'chart-wrapper'
    else
      chart_container
    end
  end

  def benchmark_chart_tag(chart_type, json_data)
    chart_config = {}
    chart_config[:no_advice] = true
    chart_config[:no_zoom] = true

    # ToDo handle this in the analytics
    json_data[:x_data].delete('School name')

    formatted_json_data = ChartDataValues.new(json_data, chart_type).process

    chart_container = content_tag(
      :div,
      '',
      id: "chart_#{chart_type}",
      class: 'analysis-chart',
      data: {
        chart_config: chart_config.merge(
          type: chart_type,
          jsonData: formatted_json_data,
          transformations: []
        )
      }
    )
    chart_container
  end
end
