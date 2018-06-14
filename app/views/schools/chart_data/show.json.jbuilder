json.charts @output.each do |chart|

  chart_data = chart[:data]
  json.chart_type chart[:chart_type]
  json.data chart_data

  if chart_data != nil && chart_data[:chart1_type] == :column
    colour_hash = { 'Degree Days' => '#232b49', 'School Day Closed' => '#3bc0f0', 'School Day Open' => '#5cb85c', 'Holiday' => '#ff4500', 'Weekend' => '#ffac21' }

    x_data_hash = chart[:data][:x_data]
    series_array = x_data_hash.map do |data_type, data|
      { name: data_type, color: colour_hash[data_type], type: 'column', data: data }
    end

    y_data_hash = chart[:data][:y2_data]
    y_data_hash.each do |data_type, data|
      series_array << { name: data_type, color: colour_hash[data_type], type: 'line', data: data, yAxis: 1 }
    end

    json.title chart[:data][:title]
    json.series_data series_array
  end
end
