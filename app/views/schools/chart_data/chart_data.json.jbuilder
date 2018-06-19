


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
    'gas' => '#3bc0f0'
  }

  json.anaylsis_type      chart[:chart_type]
  json.title              chart_data[:title]
  json.chart1_type        chart_data[:chart1_type]
  json.chart1_subtype     chart_data[:chart1_subtype]
  json.y_axis_label       chart_data[:y_axis_label]
  json.x_axis_categories  chart_data[:x_axis]
  json.advice_header      chart_data[:advice_header] unless chart_data[:advice_header].nil?
  json.advice_footer      chart_data[:advice_footer] unless chart_data[:advice_footer].nil?

  if chart_data[:chart1_type] == :column || chart_data[:chart1_type] == :bar

    x_data_hash = chart[:data][:x_data]

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

    json.series_data series_array

  elsif chart_data[:chart1_type] == :line

    x_data_hash = chart[:data][:x_data]

    colour_options = ['#3bc0f0', '#3bc0f0']

    series_array = x_data_hash.each_with_index.map do |(data_type, data), index|
      { name: data_type, color: colour_options[index], type: chart_data[:chart1_type], data: data }
    end

    json.series_data series_array

  elsif chart_data[:chart1_type] == :pie

    x_data_hash = chart[:data][:x_data]

    data_points = x_data_hash.map do |data_type, data|
      { name: data_type, color: colour_hash[data_type], type: chart_data[:chart1_type], y: data[0] }
    end

    series_array = { name: chart_data[:title], colorByPoint: true, data: data_points }
    json.series_data series_array
  end

end

# json.old @output.each do |chart|
#   chart_data = chart[:data]
#   json.chart_type chart[:chart_type]
#   json.data chart_data

#   if chart_data != nil

#     json.title chart_data[:title]

#     colour_hash = {
#       'Degree Days' => '#232b49',
#       'School Day Closed' => '#3bc0f0',
#       'School Day Open' => '#5cb85c',
#       'Holiday' => '#ff4500',
#       'Weekend' => '#ffac21',
#       'electricity' => '#ff4500',
#       'gas' => '#3bc0f0'
#     }

#     json.y_axis_label chart_data[:y_axis_label]

#     if chart_data[:chart1_type] == :column || chart_data[:chart1_type] == :bar

#       x_data_hash = chart[:data][:x_data]
#       series_array = x_data_hash.each_with_index.map do |(data_type, data), index|
#         { name: data_type, color: colour_hash[data_type], type: chart_data[:chart1_type], data: data, index: index }
#       end

#       if chart[:data][:y2_data] != nil
#         y_data_hash = chart[:data][:y2_data]
#         y_data_hash.each do |data_type, data|
#           series_array << { name: data_type, color: colour_hash[data_type], type: 'line', data: data, yAxis: 1 }
#         end
#       end

#       json.series_data series_array

#     elsif chart_data[:chart1_type] == :line

#       x_data_hash = chart[:data][:x_data]

#       series_array = x_data_hash.map do |data_type, data|
#         { name: data_type, color: '#ff4500', type: chart_data[:chart1_type], data: data }
#       end

#       json.series_data series_array
#     elsif chart_data[:chart1_type] == :pie
#       x_data_hash = chart[:data][:x_data]
#       data_points = x_data_hash.map do |data_type, data|
#         { name: data_type, color: colour_hash[data_type], type: chart_data[:chart1_type], y: data[0] }
#       end

#       series_array = { name: chart_data[:title], colorByPoint: true, data: data_points }
#       json.series_data series_array
#     end
#   end
# end