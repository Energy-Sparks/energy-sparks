json.charts @output.each do |chart|
  chart_data = chart[:data]
  next if chart_data.nil?

  colour_hash = {
    'Degree Days' => '#232b49',
    'School Day Closed' => '#3bc0f0',
    'School Day Open' => '#5cb85c',
    'Holiday' => '#ff4500',
    'Weekend' => '#ffac21',
    'electricity' => '#ff4500',
    'gas' => '#3bc0f0',
    'Heating Day' => '#3bc0f0',
    'Non Heating Day' =>'#5cb85c',
    'Heating Day Model' => '#ff4500',
    'Non Heating Day Model' => '#ffac21'
  }

  json.anaylsis_type      chart[:chart_type]
  json.title              chart_data[:title]
  json.chart1_type        chart_data[:chart1_type]
  json.chart1_subtype     chart_data[:chart1_subtype]
  json.y_axis_label       chart_data[:y_axis_label]
  json.x_axis_categories  chart_data[:x_axis]
  json.advice_header      chart_data[:advice_header] unless chart_data[:advice_header].nil?
  json.advice_footer      chart_data[:advice_footer] unless chart_data[:advice_footer].nil?

  x_data_hash = chart[:data][:x_data]

  series_array = []

  if chart_data[:chart1_type] == :column || chart_data[:chart1_type] == :bar

    series_array = x_data_hash.each_with_index.map do |(data_type, data), index|
      { name: data_type, color: colour_hash[data_type], type: chart_data[:chart1_type], data: data, index: index }
    end

    if chart_data[:y2_data] != nil && chart_data[:y2_chart_type] == :line
      json.y2_axis_label chart_data[:y2_data].keys[0]
      y_data_hash = chart[:data][:y2_data]
      y_data_hash.each do |data_type, data|
        series_array << { name: data_type, color: colour_hash[data_type], type: 'line', data: data, yAxis: 1 }
      end
    end

  elsif chart_data[:chart1_type] == :scatter

    x_data_hash.each do |data_type, data|

      scatter_data = chart_data[:x_axis].each_with_index.collect do |one_x_axis_point, index|
        [one_x_axis_point, data[index]]
      end
      series_array << { name: data_type, color: colour_hash[data_type], data: scatter_data}
    end

  elsif chart_data[:chart1_type] == :line

    colour_options = ['#5cb85c', '#ffac21']

    series_array = x_data_hash.each_with_index.map do |(data_type, data), index|
      if data_type.start_with?('Energy')
        data_type = data_type.scan(/\d+|[A-Za-z]+/).drop(1).each_slice(4).to_a.map { |bit| bit.join(' ') }.join(' - ')
      end
      { name: data_type, color: colour_options[index], type: chart_data[:chart1_type], data: data }
    end

  elsif chart_data[:chart1_type] == :pie

    data_points = x_data_hash.map do |data_type, data|
      { name: data_type, color: colour_hash[data_type], type: chart_data[:chart1_type], y: data[0] }
    end

    series_array = { name: chart_data[:title], colorByPoint: true, data: data_points }
  end

  json.series_data series_array
end
