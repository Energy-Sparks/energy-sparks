module ChartHelper
  def chart_tag(school, chart_type, index: 1, show_advice: true, no_zoom: false, chart_config: {}, html_class: 'analysis-chart')
    html_chart_data = chart_config.inject({}) do |collection, (data_item_key, data_item_value)|
      collection["chart-#{data_item_key.to_s.parameterize}"] = data_item_value
      collection
    end
    html_chart_data[:no_advice] = true unless show_advice
    html_chart_data[:no_zoom] = true if no_zoom
    content_tag(
      :div,
      '',
      id: "chart_#{index}",
      class: html_class,
      data: {
        "chart-index" => index,
        "chart-type" => chart_type,
        "chart-annotations" => school_annotations_path(school),
        "chart-json" => school_chart_path(school, format: :json),
        "chart-transformations" => []
      }.merge(html_chart_data)
    )
  end
end
