module ChartHelper
  def chart_tag(school, chart_type, wrap: true, show_advice: true, no_zoom: false, chart_config: {}, html_class: 'analysis-chart')
    chart_config[:no_advice] = !show_advice
    chart_config[:no_zoom] = no_zoom
    chart_container = content_tag(
      :div,
      '',
      id: chart_config[:mpan_mprn].present? ? "chart_#{chart_type}_#{chart_config[:mpan_mprn]}" : "chart_#{chart_type}",
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
    chart_container += "<div id='chart-error' class='d-none'>#{I18n.t('chart_data_values.standard_error_message')}</div>".html_safe
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

    number_of_records = json_data[:x_axis].size
    chart_height = [30 * number_of_records, 700].max

    output = ChartDataValues.new(json_data, chart_type).process
    formatted_json_data = ChartDataValues.as_chart_json(output)

    chart_container = content_tag(
      :div,
      '',
      id: "chart_#{chart_type}",
      class: 'analysis-chart',
      style: "height:#{chart_height}px;",
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

  def bullet_chart_series(fuel_progress, units = :kwh)
    return {
      "y": bullet_chart_number(fuel_progress.usage, units),
      "target": bullet_chart_number(fuel_progress.target, units)
    }.to_json
  end

  def bullet_chart_bands(fuel_progress, units = :kwh)
    [{
        from: 0,
        to: bullet_chart_number(fuel_progress.target, units),
        color: '#50E3C2'
    }, {
        from: bullet_chart_number(fuel_progress.target, units),
        to: 1_000_000,
        color: '#FF3A5B'
    }].to_json
  end

  def bullet_chart_number(number, units = :kwh)
    format_target(number, units).delete(",").to_i
  end

  def possible_y1_axis_choices
    Charts::YAxisSelectionService.possible_y1_axis_choices
  end

  def select_y_axis(school, chart_name, default = nil)
    Charts::YAxisSelectionService.new(school, chart_name).select_y_axis || default
  end

  def create_chart_config(school, chart_name, mpan_mprn = nil)
    config = {}
    config[:mpan_mprn] = mpan_mprn if mpan_mprn.present?
    y_axis = select_y_axis(school, chart_name)
    config[:y_axis_units] = y_axis if y_axis.present?
    config
  end
end
