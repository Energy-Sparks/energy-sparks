module ChartHelper
  def chart_tag(school, chart_type, show_advice: true, no_zoom: false, chart_config: {}, html_class: 'analysis-chart')
    chart_config[:no_advice] = !show_advice
    chart_config[:no_zoom] = no_zoom
    content_tag(
      :div,
      '',
      id: "chart_#{chart_type}",
      class: html_class,
      data: {
        chart_config: chart_config.merge(
          type: chart_type,
          annotations: school_annotations_path(school),
          json: school_chart_path(school, format: :json),
          transformations: []
        )
      }
    )
  end
end
