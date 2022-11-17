class ChartDataValues
  attr_reader :anaylsis_type, :title, :subtitle, :chart1_type, :chart1_subtype,
              :y_axis_label, :x_axis_label, :x_axis_categories, :x_max_value, :x_min_value,
              :advice_header, :advice_footer, :y2_axis_label, :y2_point_format, :y2_max, :x_axis_ranges, :annotations,
              :transformations, :allowed_operations, :drilldown_available, :parent_timescale_description,
              :uses_time_of_day, :y1_axis_choices, :explore_message, :pinch_and_zoom_message, :click_and_drag_message

  DARK_ELECTRICITY = '#007EFF'.freeze
  MIDDLE_ELECTRICITY = '#02B8FF'.freeze
  LIGHT_ELECTRICITY = '#59D0FF'.freeze
  DARK_ELECTRICITY_LINE = '#232B49'.freeze
  LIGHT_ELECTRICITY_LINE = '#007EFF'.freeze
  DARK_GAS = '#FF8438'.freeze
  MIDDLE_GAS = '#FFB138'.freeze
  LIGHT_GAS = '#FFC73E'.freeze
  DARK_GAS_LINE = '#FF3A5B'.freeze
  LIGHT_GAS_LINE = '#FCB43A'.freeze
  DARK_STORAGE = '#7C3AFF'.freeze
  LIGHT_STORAGE = '#E097FC'.freeze
  GREEN = '#5cb85c'.freeze
  STORAGE_HEATER = "#501e74".freeze
  MONEY = '#232B49'.freeze

  X_AXIS_CATEGORIES = %w(S M T W T F S).freeze

  def initialize(chart, chart_type, transformations: [], allowed_operations: {}, drilldown_available: false, parent_timescale_description: nil, y1_axis_choices: [])
    if chart
      @chart_type         = chart_type
      @chart              = chart
      @title              = chart[:title]
      @subtitle           = chart[:subtitle]
      @x_axis_categories  = translate_categories_for(chart[:x_axis])
      @x_axis_ranges      = chart[:x_axis_ranges] # Not actually used but range of actual dates
      @x_max_value        = chart[:x_max_value]
      @x_min_value        = chart[:x_min_value]
      @chart1_type        = chart[:chart1_type]
      @chart1_subtype     = chart[:chart1_subtype]
      @x_axis_label       = chart[:x_axis_label]
      @y_axis_label       = format_y_axis_label_for(chart[:y_axis_label])
      @configuration      = chart[:configuration]
      @advice_header      = chart[:advice_header]
      @advice_footer      = chart[:advice_footer]
      @x_data             = translate_data_keys_for(chart[:x_data])
      @y2_data            = translate_data_keys_for(chart[:y2_data])
      @y2_chart_type      = chart[:y2_chart_type]
      @annotations        = []
      @y2_axis_label = '' # Set later
      @transformations = transformations
      @allowed_operations = allowed_operations
      @drilldown_available = drilldown_available
      @parent_timescale_description = parent_timescale_description
      @uses_time_of_day = false
      @y1_axis_choices = y1_axis_choices
      @explore_message = I18n.t('chart_data_values.explore_message')
      @pinch_and_zoom_message = I18n.t('chart_data_values.pinch_and_zoom_message')
      @click_and_drag_message = I18n.t('chart_data_values.click_and_drag_message')
    else
      @title = I18n.t('chart_data_values.not_enough_data_message', chart_type: chart_type.to_s.capitalize)
    end
    @used_name_colours = []
  end

  def translate_categories_for(categories)
    return categories unless categories.is_a? Array

    categories.map { |category_label| translated_series_item_for(category_label) }
  end

  def translate_data_keys_for(data)
    return unless data.present?

    data.transform_keys { |series_item| translated_series_item_for(series_item) }
  end

  def format_y_axis_label_for(y_axis_label)
    if y_axis_label == 'kg CO2'
      'kg<br>CO2'
    else
      y_axis_label
    end
  end

  def process
    return self if @chart.nil?
    @x_data_hash = reverse_x_data_if_required

    @series_data = []

    @annotations = annotations_configuration

    if @chart1_type == :column || @chart1_type == :bar
      if @chart_type.match?(/^calendar_picker/) && @chart[:configuration][:series_breakdown] != :meter
        usage_column
      else
        column_or_bar
      end
    elsif @chart1_type == :scatter
      scatter_and_trendline
    elsif @chart1_type == :line
      #TODO chart colours that show gas/electricity/storage should all be using usage_line.
      if @chart_type.match?(/^targeting_and_tracking/) || @chart_type.match?(/^calendar_picker/) && @chart[:configuration][:series_breakdown] != :meter
        usage_line
      else
        line
      end
    elsif @chart1_type == :pie
      pie
    end
    self
  end

  def series_data
    return @series_data unless @series_data.is_a? Array

    # Temporary TOFIX TODO as analytics should not return negative values
    @series_data.map do |series|
      series[:data] = series[:data].map { |v| v.is_a?(Float) ? v.round(8) : v }
      series
    end
  end

  def colour_lookup
    @colour_lookup ||= {
      I18n.t("analytics.series_data_manager.series_name.#{Series::DegreeDays::DEGREEDAYS_I18N_KEY}") => '#232b49',
      I18n.t("analytics.series_data_manager.series_name.#{Series::Temperature::TEMPERATURE_I18N_KEY}") => '#232b49',
      I18n.t("analytics.series_data_manager.series_name.#{Series::DayType::SCHOOLDAYCLOSED_I18N_KEY}") => '#3bc0f0',
      I18n.t("analytics.series_data_manager.series_name.#{Series::DayType::SCHOOLDAYOPEN_I18N_KEY}") => GREEN,
      I18n.t("analytics.series_data_manager.series_name.#{Series::DayType::HOLIDAY_I18N_KEY}") => '#ff4500',
      I18n.t("analytics.series_data_manager.series_name.#{Series::DayType::WEEKEND_I18N_KEY}") => '#ffac21',
      I18n.t("analytics.series_data_manager.series_name.#{Series::HeatingNonHeating::HEATINGDAY_I18N_KEY}") => '#3bc0f0',
      I18n.t("analytics.series_data_manager.series_name.#{Series::HeatingNonHeating::NONHEATINGDAY_I18N_KEY}") => GREEN,
      I18n.t("analytics.series_data_manager.series_name.#{Series::HotWater::USEFULHOTWATERUSAGE_I18N_KEY}") => '#3bc0f0',
      I18n.t("analytics.series_data_manager.series_name.#{Series::HotWater::WASTEDHOTWATERUSAGE_I18N_KEY}") => '#ff4500',
      I18n.t("analytics.series_data_manager.series_name.#{Series::MultipleFuels::SOLARPV_I18N_KEY}") => '#ffac21',
      I18n.t('analytics.series_data_manager.series_name.electricity') => MIDDLE_ELECTRICITY,
      I18n.t('analytics.series_data_manager.series_name.gas') => MIDDLE_GAS,
      I18n.t('analytics.series_data_manager.series_name.storage_heaters') => STORAGE_HEATER,
      '£' => MONEY,
      I18n.t("analytics.series_data_manager.series_name.#{SolarPVPanels::SOLAR_PV_ONSITE_ELECTRIC_CONSUMPTION_METER_NAME_I18N_KEY}") => GREEN,
      I18n.t("analytics.series_data_manager.series_name.#{SolarPVPanels::ELECTRIC_CONSUMED_FROM_MAINS_METER_NAME}") => MIDDLE_ELECTRICITY,
      I18n.t("analytics.series_data_manager.series_name.#{SolarPVPanels::SOLAR_PV_EXPORTED_ELECTRIC_METER_NAME}") => LIGHT_GAS_LINE,
      I18n.t('analytics.series_data_manager.y2_solar_label') => MIDDLE_GAS,
      I18n.t('analytics.series_data_manager.y2_rating') => '#232b49'
    }
  end

  def work_out_best_colour(data_type)
    from_hash = colour_lookup[data_type]
    return from_hash unless from_hash.nil?

    using_name = colour_lookup.detect do |key, colour|
      data_type.to_s.downcase.include?(key.downcase) && !@used_name_colours.include?(colour)
    end
    unless using_name.nil?
      @used_name_colours << using_name.second
      using_name.second
    end
  end

  def self.as_chart_json(output)
    [
      :title,
      :subtitle,
      :chart1_type,
      :chart1_subtype,
      :y_axis_label,
      :x_axis_label,
      :x_axis_categories,
      :x_max_value,
      :x_min_value,
      :advice_header,
      :advice_footer,
      :y2_axis_label,
      :y2_point_format,
      :y2_max,
      :series_data,
      :annotations,
      :allowed_operations,
      :drilldown_available,
      :transformations,
      :parent_timescale_description,
      :uses_time_of_day,
      :y1_axis_choices,
      :explore_message,
      :pinch_and_zoom_message,
      :click_and_drag_message
    ].inject({}) do |json, field|
      json[field] = output.public_send(field)
      json
    end
  end

  def translated_series_item_for(series_key_as_string)
    i18n_key = series_translation_key_lookup[series_key_as_string]
    return series_key_as_string unless i18n_key

    I18n.t("analytics.series_data_manager.series_name.#{i18n_key}")
  end

  def series_translation_key_lookup
    @series_translation_key_lookup ||= {
      Series::DegreeDays::DEGREEDAYS => Series::DegreeDays::DEGREEDAYS_I18N_KEY,
      Series::Temperature::TEMPERATURE => Series::Temperature::TEMPERATURE_I18N_KEY,
      Series::DayType::SCHOOLDAYCLOSED => Series::DayType::SCHOOLDAYCLOSED_I18N_KEY,
      Series::DayType::SCHOOLDAYOPEN => Series::DayType::SCHOOLDAYOPEN_I18N_KEY,
      Series::DayType::HOLIDAY => Series::DayType::HOLIDAY_I18N_KEY,
      Series::DayType::WEEKEND => Series::DayType::WEEKEND_I18N_KEY,
      Series::DayType::STORAGE_HEATER_CHARGE => Series::DayType::STORAGE_HEATER_CHARGE_I18N_KEY,
      Series::HotWater::USEFULHOTWATERUSAGE => Series::HotWater::USEFULHOTWATERUSAGE_I18N_KEY,
      Series::HotWater::WASTEDHOTWATERUSAGE => Series::HotWater::WASTEDHOTWATERUSAGE_I18N_KEY,
      Series::MultipleFuels::SOLARPV => Series::MultipleFuels::SOLARPV_I18N_KEY,
      Series::Irradiance::IRRADIANCE => Series::Irradiance::IRRADIANCE_I18N_KEY,
      Series::GridCarbon::GRIDCARBON => Series::GridCarbon::GRIDCARBON_I18N_KEY,
      Series::GasCarbon::GASCARBON => Series::GasCarbon::GASCARBON_I18N_KEY,
      Series::HeatingNonHeating::HEATINGDAY => Series::HeatingNonHeating::HEATINGDAY_I18N_KEY,
      Series::HeatingNonHeating::NONHEATINGDAY => Series::HeatingNonHeating::NONHEATINGDAY_I18N_KEY,
      Series::HeatingNonHeating::HEATINGDAYWARMWEATHER => Series::HeatingNonHeating::HEATINGDAYWARMWEATHER_I18N_KEY,
      Series::MultipleFuels::ELECTRICITY => Series::MultipleFuels::ELECTRICITY_I18N_KEY,
      Series::MultipleFuels::GAS => Series::MultipleFuels::GAS_I18N_KEY,
      Series::MultipleFuels::STORAGEHEATERS => Series::MultipleFuels::STORAGEHEATERS_I18N_KEY,
      Series::MultipleFuels::SOLARPV => Series::MultipleFuels::SOLARPV_I18N_KEY,
      Series::PredictedHeat::PREDICTEDHEAT => Series::PredictedHeat::PREDICTEDHEAT_I18N_KEY,
      Series::TargetDegreeDays::TARGETDEGREEDAYS => Series::TargetDegreeDays::TARGETDEGREEDAYS_I18N_KEY,
      Series::Cusum::CUSUM => Series::Cusum::CUSUM_I18N_KEY,
      Series::Baseload::BASELOAD => Series::Baseload::BASELOAD_I18N_KEY,
      Series::PeakKw::PEAK_KW => Series::PeakKw::PEAK_KW_I18N_KEY,
      Series::HeatingDayType::SCHOOLDAYHEATING => Series::HeatingDayType::SCHOOLDAYHEATING_I18N_KEY,
      Series::HeatingDayType::HOLIDAYHEATING => Series::HeatingDayType::HOLIDAYHEATING_I18N_KEY,
      Series::HeatingDayType::WEEKENDHEATING => Series::HeatingDayType::WEEKENDHEATING_I18N_KEY,
      Series::HeatingDayType::SCHOOLDAYHOTWATER => Series::HeatingDayType::SCHOOLDAYHOTWATER_I18N_KEY,
      Series::HeatingDayType::HOLIDAYHOTWATER => Series::HeatingDayType::HOLIDAYHOTWATER_I18N_KEY,
      Series::HeatingDayType::WEEKENDHOTWATER => Series::HeatingDayType::WEEKENDHOTWATER_I18N_KEY,
      Series::HeatingDayType::BOILEROFF => Series::HeatingDayType::BOILEROFF_I18N_KEY,
      Series::NoBreakdown::NONE => Series::NoBreakdown::NONE_I18N_KEY,
      AggregatorBenchmarks.exemplar_school_name => 'exemplar_school',
      AggregatorBenchmarks.benchmark_school_name => 'benchmark_school',
      OpenCloseTime.community => OpenCloseTime::COMMUNITY_I18N_KEY,
      OpenCloseTime.community_baseload => OpenCloseTime::COMMUNITY_BASELOAD_I18N_KEY,
      SolarPVPanels::SOLAR_PV_ONSITE_ELECTRIC_CONSUMPTION_METER_NAME => SolarPVPanels::SOLAR_PV_ONSITE_ELECTRIC_CONSUMPTION_METER_NAME_I18N_KEY,
      SolarPVPanels::SOLAR_PV_EXPORTED_ELECTRIC_METER_NAME => SolarPVPanels::SOLAR_PV_EXPORTED_ELECTRIC_METER_NAME_I18N_KEY,
      SolarPVPanels::ELECTRIC_CONSUMED_FROM_MAINS_METER_NAME => SolarPVPanels::ELECTRIC_CONSUMED_FROM_MAINS_METER_NAME_I18N_KEY
    }
  end

private

  def start_date_from_label(full_label)
    # Remove leading Energy:
    date_string = tidy_label(full_label)
    Date.parse(date_string)
  rescue ArgumentError
    nil
  end

  def format_teachers_label(full_label)
    start_date = start_date_from_label(full_label)
    return full_label unless start_date
    end_date = start_date + 6.days
    "#{I18n.l(start_date, format: '%a %d/%m/%Y')} - #{I18n.l(end_date, format: '%a %d/%m/%Y')}"
  rescue ArgumentError
    full_label
  end

  def usage_column
    @series_data = @x_data_hash.each_with_index.map do |(data_type, data), index|
      colour = teachers_chart_colour(index)
      #get the start date
      start_date = start_date_from_label(data_type)

      #run map over the data to turn it into a hash of {y: d, day: formatted_date from index}
      if start_date
        data.map!.with_index {|v, i| { y: v, day: I18n.l(start_date.next_day(i), format: '%a %d/%m/%Y') } }
      end

      #add some useful cue to the json to indicate it should use an alternate formatter
      #e.g. pointFormat: :day, :orderedPoint
      { name: format_teachers_label(data_type), color: colour, type: @chart1_type, data: data, index: index, day_format: start_date.present? }
    end
  end

  def teachers_chart_colour(index)
    if @chart_type.match?(/_gas_/)
      index.zero? ? DARK_GAS : LIGHT_GAS
    elsif @chart_type.match?(/_storage_/)
      index.zero? ? DARK_STORAGE : LIGHT_STORAGE
    else
      index.zero? ? DARK_ELECTRICITY : LIGHT_ELECTRICITY
    end
  end

  def wrap_label_as_html(label)
    '<span>' + label.split.join('<br />') + '</span>'
  end

  def column_or_bar
    @series_data = @x_data_hash.each_with_index.map do |(data_type, data), index|
      data_type = tidy_label(data_type)
      colour = work_out_best_colour(data_type)

      # ToDo is there a better way we can detect this reliably?
      if data.detect { |record| record.is_a?(TimeOfDay) }
        @uses_time_of_day = true
        data = data.map { |record| record.present? ? convert_relative_time(record.relative_time) : nil }
      end

      { name: data_type, color: colour, type: @chart1_type, data: data, index: index }
    end

    if @y2_data != nil && @y2_chart_type == :line
      y2_data_title = @y2_data.keys[0]
      @y2_axis_label, @y2_point_format, @y2_max = label_point_and_max_for(y2_data_title)

      @y2_data.each do |data_type, data|
        data_type = I18n.t('analytics.series_data_manager.y2_solar_label') if y2_is_solar?(data_type)
        @series_data << { name: data_type, color: work_out_best_colour(data_type), type: 'line', data: data, yAxis: 1 }
      end
    end
  end

  def label_point_and_max_for(y2_data_title)
    if y2_is_temperature?(y2_data_title)
      ['°C', '{point.y:.2f} °C',]
    elsif y2_is_degree_days?(y2_data_title)
      [
        wrap_label_as_html(y2_data_title),
        "{point.y:.2f} #{y2_data_title}",
      ]
    elsif y2_is_carbon_intensity?(y2_data_title)
      ['kg/kWh', '{point.y:.2f} kg/kWh', 0.5]

    elsif y2_is_carbon?(y2_data_title)
      ['kWh', '{point.y:.2f} kWh',]
    elsif y2_is_solar?(y2_data_title)
      [
        I18n.t('analytics.series_data_manager.y2_solar_html'),
        '{point.y:.2f} W/m2',
      ]
    elsif y2_is_rating?(y2_data_title)
      [I18n.t('analytics.series_data_manager.y2_rating'),]
    end
  end

  def trendline?(data_type)
    data_type.to_s.downcase.start_with?("trendline")
  end

  def scatter_and_trendline
    @x_data_hash.each do |data_type, data|
      @series_data << {
        name: data_type,
        color: work_out_best_colour(data_type),
        data: scatter_and_trendline_series_data_for(data_type, data)
      }
    end
  end

  def scatter_and_trendline_series_data_for(data_type, data)
    if trendline?(data_type)
      reduced_trendline_series_data_for(data)
    else
      scatter_series_data_for(data)
    end
  end

  def reduced_trendline_series_data_for(data)
    # Trendline data needs to be reduced to maximum and minimum values only to reliably plot
    # a non-breaking straight line between two points.
    maximum_value = data.compact.max
    minimum_value = data.compact.min
    reduced_data = data.map { |value| [maximum_value, minimum_value].include?(value) ? value : nil }
    @x_axis_categories.zip(reduced_data)
  end

  def scatter_series_data_for(data)
    @x_axis_categories.zip(data)
  end

  def usage_line
    colour_options = case @chart_type
                     when /_gas_/ then [DARK_GAS, LIGHT_GAS]
                     when /_storage_/ then [DARK_STORAGE, LIGHT_STORAGE]
                     else [DARK_ELECTRICITY, LIGHT_ELECTRICITY]
                     end
    line(colour_options: colour_options)
  end

  def line(colour_options: ['#5cb85c', '#ffac21'])
    @series_data = @x_data_hash.each_with_index.map do |(data_type, data), index|
      data_type = tidy_label(data_type)
      { name: data_type, color: colour_options[index], type: @chart1_type, data: data }
    end

    if @y2_data != nil && @y2_chart_type == :line
      @series_data = @x_data_hash.each_with_index.map do |(data_type, data), index|
        data_type = tidy_and_keep_label(data_type)
        { name: data_type, color: colour_options[index], type: @chart1_type, data: data }
      end

      @y2_axis_label = @y2_data.keys[0]
      @y2_axis_label = 'Temperature' if @y2_axis_label.start_with?('Temp')

      @y2_data.each do |data_type, data|
        data_type = tidy_and_keep_label(data_type)
        @series_data << { name: data_type, color: work_out_best_colour(data_type), type: 'line', data: data, yAxis: 1 }
      end
    else
      @series_data = @x_data_hash.each_with_index.map do |(data_type, data), index|
        data_type = tidy_label(data_type)
        { name: data_type, color: colour_options[index], type: @chart1_type, data: data }
      end
    end
  end

  def pie
    data_points = @x_data_hash.map do |data_type, data|
      { name: data_type, color: work_out_best_colour(data_type), type: @chart1_type, y: data[0] }
    end
    @series_data = { name: @title, colorByPoint: true, data: data_points }
  end

  def reverse_x_data_if_required
    if @chart.dig(:data, :configuration, :series_name_order) == :reverse
      @x_data.reverse_each.to_h
    else
      @x_data
    end
  end

  def convert_relative_time(relative_time, offset = 1.hour)
    (relative_time + offset).to_i * 1000
  end

  def label_is_energy_plus?(label)
    label.is_a?(String) && label.start_with?('Energy') && label.length > 6
  end

  def tidy_label(current_label)
    if label_is_energy_plus?(current_label)
      current_label = sort_out_dates_when_tidying_labels(current_label)
    end
    current_label
  end

  def tidy_and_keep_label(current_label)
    label_bit = current_label.scan(/\d+|[A-Za-z]+/).shift
    label_bit + ' ' + sort_out_dates_when_tidying_labels(current_label)
  end

  def sort_out_dates_when_tidying_labels(current_label)
    date_to_and_from = current_label.scan(/\d+|[A-Za-z]+/).drop(1).each_slice(4).to_a

    if date_to_and_from.size > 1 && date_to_and_from[0][3] != date_to_and_from[1][3]
      date_to_and_from[0].delete_at(0)
      date_to_and_from[1].delete_at(0)
    end
    date_to_and_from.map { |bit| bit.join(' ') }.join(' - ')
  end

  def annotations_configuration
    case @chart_type
    when :management_dashboard_group_by_week_electricity, :management_dashboard_group_by_week_gas, :electricity_co2_last_year_weekly_with_co2_intensity then :weekly
    when :baseload_lastyear then :daily
    end
  end

  def y2_is_temperature?(y2_data_title)
    y2_data_title == translated_series_item_for(Series::Temperature::TEMPERATURE)
  end

  def y2_is_degree_days?(y2_data_title)
    y2_data_title == translated_series_item_for(Series::DegreeDays::DEGREEDAYS)
  end

  def y2_is_carbon_intensity?(y2_data_title)
    return true if y2_data_title == translated_series_item_for(Series::GridCarbon::GRIDCARBON)
    return true if y2_data_title == translated_series_item_for(Series::GasCarbon::GASCARBON)
    return true if y2_data_title.downcase.starts_with?('carbon intensity')

    false
  end

  def y2_is_carbon?(y2_data_title)
    y2_data_title.starts_with?('Carbon')
  end

  def y2_is_solar?(y2_data_title)
    return true if y2_data_title == translated_series_item_for(Series::Irradiance::IRRADIANCE)
    return true if y2_data_title.downcase.starts_with?('solar') # TODO match against series constants

    false
  end

  def y2_is_rating?(y2_data_title)
    y2_data_title.casecmp('rating').zero?
  end
end
