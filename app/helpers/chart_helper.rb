module ChartHelper
  def chart_tag(school, chart_type, wrap: true, show_advice: false, no_zoom: false, chart_config: {}, html_class: 'analysis-chart', autoload_chart: true, fuel_type: nil)
    chart_config[:no_advice] = !show_advice
    chart_config[:no_zoom] = no_zoom
    chart_container = content_tag(
      :div,
      '',
      id: chart_config[:mpan_mprn].present? ? "chart_#{chart_type}_#{chart_config[:mpan_mprn]}" : "chart_#{chart_type}",
      class: html_class,
      data: {
        autoload_chart: autoload_chart,
        chart_config: chart_config.merge(
          type: chart_type,
          annotations: school_annotations_path(school, fuel_type: fuel_type),
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
      class: 'analysis-chart tabbed',
      style: "height:#{chart_height}px;",
      data: {
        autoload_chart: true,
        chart_config: chart_config.merge(
          type: chart_type,
          jsonData: formatted_json_data,
          transformations: []
        )
      }
    )
    chart_container
  end

  def possible_y1_axis_choices
    Charts::YAxisSelectionService.possible_y1_axis_choices
  end

  def select_y_axis(school, chart_name, default = nil)
    Charts::YAxisSelectionService.new(school, chart_name).select_y_axis || default
  end

  def create_chart_config(school, chart_name, mpan_mprn = nil, apply_preferred_units: true, export_title: '', export_subtitle: '')
    config = {}
    config[:mpan_mprn] = mpan_mprn if mpan_mprn.present?
    y_axis = apply_preferred_units ? select_y_axis(school, chart_name) : nil
    config[:y_axis_units] = y_axis if y_axis.present?
    config[:export_title] = export_title
    config[:export_subtitle] = export_subtitle
    config
  end

  def create_chart_descriptions(key, date_ranges_by_meter)
    date_ranges_by_meter.each_with_object({}) do |(mpan_mprn, dates), date_ranges|
      date_ranges[mpan_mprn] = I18n.t(key,
        start_date: dates[:start_date].to_s(:es_short),
        end_date: dates[:end_date].to_s(:es_short),
        meter: dates[:meter].present? ? dates[:meter].name_or_mpan_mprn : mpan_mprn)
    end
  end
end
