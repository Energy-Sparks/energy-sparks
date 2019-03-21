module AlertsChartsHelper
  def sort_out_data_for_alerts_chart(content)
    data_string = ''
    content = HashWithIndifferentAccess.new(content)
    content[:x_data].map.each_with_index do |(k, v), index|
      data_string = data_string + ',' unless index == 0
      data_string = data_string + '{ "name": "' +  k + '", "y": ' + v[0].to_s + ' } '
    end

    '{ "name": "' + content[:title] + '", "colorByPoint": "true", "data": [' + data_string + '] }'
  end
end
