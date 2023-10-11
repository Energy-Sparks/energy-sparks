# $yellow: #ffee8f;       /* yellow rgb(255,238,143) */
# $light-orange: #ffac21; /* orange  rgb(255,172,33) */
# $dark-orange: #ff4500;  /* almost red; rgb(255,69,0) */

# $light-blue: #3bc0f0;   /* cyanish rgb(59,192,240) */
# $dark-blue: #232b49;    /* very dark blue rgb(35,43,73) */

# $green: #5cb85c;        /* nice green rgb(92,184,92) */

# Hacky
chart_index = -1

json.charts @output.each do |chart|
  chart_index += 1

  # This is to handle the side by side charts which behave slightly
  # differently - needs sorting at some point
  chart_data = chart[:data].nil? ? chart : chart[:data]

  next if chart_data.nil?

  colour_hash = {
    Series::DegreeDays::DEGREEDAYS => '#232b49',
    Series::Temperature::TEMPERATURE => '#232b49',
    Series::DayType::SCHOOLDAYCLOSED => '#3bc0f0',
    Series::DayType::SCHOOLDAYOPEN => '#5cb85c',
    Series::DayType::HOLIDAY => '#ff4500',
    Series::DayType::WEEKEND => '#ffac21',
    'electricity' => '#ff4500',
    '' => '#ff4500',
    'gas' => '#3bc0f0',
    Series::HeatingNonHeating::HEATINGDAY => '#3bc0f0',
    Series::HeatingNonHeating::NONHEATINGDAY => '#5cb85c',
    Series::HotWater::USEFULHOTWATERUSAGE => '#3bc0f0',
    Series::HotWater::WASTEDHOTWATERUSAGE => '#ff4500',
    Series::MultipleFuels::SOLARPV => '#ffac21' # 'solar pv (consumed onsite)'
  }

  json.chart_index        chart_index
  json.title              chart_data[:title]
  json.chart1_type        chart_data[:chart1_type]
  json.chart1_subtype     chart_data[:chart1_subtype]
  json.x_axis_label       chart_data[:x_axis_label]
  json.y_axis_label       chart_data[:y_axis_label]
  json.x_axis_categories  chart_data[:x_axis]
  json.advice_header      chart_data[:advice_header] unless chart_data[:advice_header].nil?
  json.advice_footer      chart_data[:advice_footer] unless chart_data[:advice_footer].nil?

  x_data_hash = if chart.dig(:data, :configuration, :series_name_order) == :reverse
                  chart_data[:x_data].reverse_each.to_h
                else
                  chart_data[:x_data]
                end

  series_array = []

  if chart_data[:chart1_type] == :column || chart_data[:chart1_type] == :bar

    series_array = x_data_hash.each_with_index.map do |(data_type, data), index|
      data_type = tidy_label(data_type)
      { name: data_type, color: colour_hash[data_type], type: chart_data[:chart1_type], data: data, index: index }
    end

    if !chart_data[:y2_data].nil? && chart_data[:y2_chart_type] == :line
      json.y2_axis_label chart_data[:y2_data].keys[0]
      y_data_hash = chart_data[:y2_data]
      y_data_hash.each do |data_type, data|
        series_array << { name: data_type, color: colour_hash[data_type], type: 'line', data: data, yAxis: 1 }
      end
    end

  elsif chart_data[:chart1_type] == :scatter

    x_data_hash.each do |data_type, data|
      scatter_data = chart_data[:x_axis].each_with_index.collect do |one_x_axis_point, index|
        [one_x_axis_point, data[index]]
      end
      series_array << { name: data_type, color: colour_hash[data_type], data: scatter_data }
    end

  elsif chart_data[:chart1_type] == :line

    colour_options = ['#5cb85c', '#ffac21']

    series_array = x_data_hash.each_with_index.map do |(data_type, data), index|
      data_type = tidy_label(data_type)
      { name: data_type, color: colour_options[index], type: chart_data[:chart1_type], data: data }
    end

    if !chart_data[:y2_data].nil? && chart_data[:y2_chart_type] == :line
      series_array = x_data_hash.each_with_index.map do |(data_type, data), index|
        data_type = tidy_and_keep_label(data_type)
        { name: data_type, color: colour_options[index], type: chart_data[:chart1_type], data: data }
      end

      y2_axis_label = chart_data[:y2_data].keys[0]
      y2_axis_label = 'Temperature' if y2_axis_label.start_with?('Temp')
      json.y2_axis_label y2_axis_label
      y_data_hash = chart_data[:y2_data]
      y_data_hash.each do |data_type, data|
        data_type = tidy_and_keep_label(data_type)
        series_array << { name: data_type, color: colour_hash[data_type], type: 'line', data: data, yAxis: 1 }
      end
    else
      series_array = x_data_hash.each_with_index.map do |(data_type, data), index|
        data_type = tidy_label(data_type)
        { name: data_type, color: colour_options[index], type: chart_data[:chart1_type], data: data }
      end

    end

  elsif chart_data[:chart1_type] == :pie

    data_points = x_data_hash.map do |data_type, data|
      { name: data_type, color: colour_hash[data_type], type: chart_data[:chart1_type], y: data[0] }
    end

    series_array = { name: chart_data[:title], colorByPoint: true, data: data_points }
  end

  json.series_data series_array
end
