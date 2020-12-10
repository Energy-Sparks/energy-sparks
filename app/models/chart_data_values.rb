class ChartDataValues
  attr_reader :anaylsis_type, :title, :subtitle, :chart1_type, :chart1_subtype,
              :y_axis_label, :x_axis_label, :x_axis_categories,
              :advice_header, :advice_footer, :y2_axis_label, :x_axis_ranges, :annotations,
              :transformations, :allowed_operations, :drilldown_available, :parent_timescale_description,
              :uses_time_of_day

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

  COLOUR_HASH = {
    SeriesNames::DEGREEDAYS => '#232b49',
    SeriesNames::TEMPERATURE => '#232b49',
    SeriesNames::SCHOOLDAYCLOSED => '#3bc0f0',
    SeriesNames::SCHOOLDAYOPEN => GREEN,
    SeriesNames::HOLIDAY => '#ff4500',
    SeriesNames::WEEKEND => '#ffac21',
    SeriesNames::HEATINGDAY => '#3bc0f0',
    SeriesNames::NONHEATINGDAY => GREEN,
    SeriesNames::HEATINGDAYMODEL => '#ff4500',
    SeriesNames::NONHEATINGDAYMODEL => '#ffac21',
    SeriesNames::USEFULHOTWATERUSAGE => '#3bc0f0',
    SeriesNames::WASTEDHOTWATERUSAGE => '#ff4500',
    SeriesNames::SOLARPV => '#ffac21', # 'solar pv (consumed onsite)'
    'electricity' => MIDDLE_ELECTRICITY,
    'gas' => MIDDLE_GAS,
    'storage heater' => STORAGE_HEATER,
    '£' => MONEY,
    'Electricity consumed from solar pv' => GREEN,
    'Solar irradiance (brightness of sunshine)' => MIDDLE_GAS,
    'Electricity consumed from mains' => MIDDLE_ELECTRICITY,
    'Exported solar electricity (not consumed onsite)' => LIGHT_GAS_LINE,
    'rating' => '#232b49'
  }.freeze

  X_AXIS_CATEGORIES = %w(S M T W T F S).freeze

  def initialize(chart, chart_type, transformations: [], allowed_operations: {}, drilldown_available: false, parent_timescale_description: nil)
    if chart
      @chart_type         = chart_type
      @chart              = chart
      @title              = chart[:title]
      @subtitle           = chart[:subtitle]
      @x_axis_categories  = chart[:x_axis]
      @x_axis_ranges      = chart[:x_axis_ranges] # Not actually used but range of actual dates
      @chart1_type        = chart[:chart1_type]
      @chart1_subtype     = chart[:chart1_subtype]
      @x_axis_label       = chart[:x_axis_label]
      @y_axis_label       = chart[:y_axis_label]
      @configuration      = chart[:configuration]
      @advice_header      = chart[:advice_header]
      @advice_footer      = chart[:advice_footer]
      @x_data             = chart[:x_data]
      @y2_data            = chart[:y2_data]
      @y2_chart_type      = chart[:y2_chart_type]
      @annotations        = []
      @y2_axis_label = '' # Set later
      @transformations = transformations
      @allowed_operations = allowed_operations
      @drilldown_available = drilldown_available
      @parent_timescale_description = parent_timescale_description
      @uses_time_of_day = false
    else
      @title = "We do not have enough data to display this chart at the moment: #{chart_type.to_s.capitalize}"
    end
    @used_name_colours = []
  end

  def process
    return self if @chart.nil?
    @x_data_hash = reverse_x_data_if_required

    @series_data = []

    @annotations = annotations_configuration

    if @chart1_type == :column || @chart1_type == :bar
      if Schools::Configuration::TEACHERS_DASHBOARD_CHARTS.include?(@chart_type)
        teachers_column
      elsif @chart_type.match?(/^calendar_picker/) && @chart[:configuration][:series_breakdown] != :meter
        usage_column
      else
        column_or_bar
      end
    elsif @chart1_type == :scatter
      scatter
    elsif @chart1_type == :line
      if @chart_type.match?(/^calendar_picker/) && @chart[:configuration][:series_breakdown] != :meter
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

  def work_out_best_colour(data_type)
    from_hash = COLOUR_HASH[data_type]
    return from_hash unless from_hash.nil?

    using_name = COLOUR_HASH.detect do |key, colour|
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
      :advice_header,
      :advice_footer,
      :y2_axis_label,
      :series_data,
      :annotations,
      :allowed_operations,
      :drilldown_available,
      :transformations,
      :parent_timescale_description,
      :uses_time_of_day
    ].inject({}) do |json, field|
      json[field] = output.public_send(field)
      json
    end
  end

private

  def format_teachers_label(full_label)
    # Remove leading Energy:
    date_string = tidy_label(full_label)
    start_date = Date.parse(date_string)
    end_date = start_date + 6.days

    "#{start_date.strftime('%a %d/%m/%Y')} - #{end_date.strftime('%a %d/%m/%Y')}"
  rescue ArgumentError
    full_label
  end

  def usage_column
    @series_data = @x_data_hash.each_with_index.map do |(data_type, data), index|
      colour = teachers_chart_colour(index)
      { name: format_teachers_label(data_type), color: colour, type: @chart1_type, data: data, index: index }
    end
  end

  def teachers_column
    @series_data = @x_data_hash.each_with_index.map do |(data_type, data), index|
      colour = teachers_chart_colour(index)

      # Override Monday, Tuesday etc
      @x_axis_categories = X_AXIS_CATEGORIES

      { name: format_teachers_label(data_type), color: colour, type: @chart1_type, data: data, index: index }
    end
  end

  def teachers_chart_colour(index)
    if Schools::Configuration.gas_dashboard_chart_types.key?(@chart_type) || @chart_type.match?(/_gas_/)
      index.zero? ? DARK_GAS : LIGHT_GAS
    elsif Schools::Configuration.storage_heater_dashboard_chart_types.key?(@chart_type) || @chart_type.match?(/_storage_/)
      index.zero? ? DARK_STORAGE : LIGHT_STORAGE
    else
      index.zero? ? DARK_ELECTRICITY : LIGHT_ELECTRICITY
    end
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
      @y2_axis_label = @y2_data.keys[0]
      @y2_data.each do |data_type, data|
        data_type = 'Solar irradiance (brightness of sunshine)' if data_type.start_with?('Solar')
        @series_data << { name: data_type, color: work_out_best_colour(data_type), type: 'line', data: data, yAxis: 1 }
      end
    end
  end

  def scatter
    @x_data_hash.each do |data_type, data|
      scatter_data = @x_axis_categories.each_with_index.collect do |one_x_axis_point, index|
        [one_x_axis_point, data[index]]
      end
      @series_data << { name: data_type, color: work_out_best_colour(data_type), data: scatter_data }
    end
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
end
