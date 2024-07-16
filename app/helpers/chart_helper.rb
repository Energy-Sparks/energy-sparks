module ChartHelper
  def create_chart_config(school, chart_name, mpan_mprn = nil, apply_preferred_units: true, export_title: '', export_subtitle: '')
    config = {}
    config[:mpan_mprn] = mpan_mprn if mpan_mprn.present?
    y_axis = apply_preferred_units ? select_y_axis(school, chart_name) : nil
    config[:y_axis_units] = y_axis if y_axis.present?
    config[:export_title] = export_title
    config[:export_subtitle] = export_subtitle
    config
  end

  def select_y_axis(school, chart_name, default = nil)
    Charts::YAxisSelectionService.new(school, chart_name).select_y_axis || default
  end

  def possible_y1_axis_choices
    Charts::YAxisSelectionService.possible_y1_axis_choices
  end

  def create_chart_descriptions(key, date_ranges_by_meter)
    date_ranges_by_meter.each_with_object({}) do |(mpan_mprn, dates), date_ranges|
      date_ranges[mpan_mprn] = I18n.t(key,
        start_date: dates[:start_date].to_fs(:es_short),
        end_date: dates[:end_date].to_fs(:es_short),
        meter: dates[:meter].present? ? dates[:meter].name_or_mpan_mprn : mpan_mprn)
    end
  end
end
