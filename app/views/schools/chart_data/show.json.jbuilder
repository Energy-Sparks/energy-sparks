
json.charts @output.each do |chart|
  json.chart_type chart[:chart_type]
  json.data chart[:data]

  json.series_1 chart[:data][:x_data]

end


# {
#   "chart_type": "benchmark",
#   "data":
#   {
#     "title": "Benchmark Comparison 21,046pounds",
#     "x_axis": ["10 Jun 2017 to 08 Jun 2018", "11 Jun 2016 to 09 Jun 2017", "13 Jun 2015 to 10 Jun 2016"],
#     "x_data":
#     {
#       "electricity": [4745.760719999999, 5554.36728, 3245.7700799999993],
#       "gas": [3129.147, 2402.8920000000007, 1967.9039999999993]
#     },
#     "chart1_type": "bar",
#     "chart1_subtype": "stacked",
#     "y_axis_label": "pounds"
#   }
# },