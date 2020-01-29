require 'rails_helper'

EXAMPLE_CONFIG =  {
    title: "Comparison of last 2 weeks gas consumption - adjusted for outside temperature £7.70",
    x_axis: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
    x_axis_ranges: [[Date.parse('Sun, 28 Apr 2019'), Date.parse('Sun, 28 Apr 2019')]],
    x_data: {"Energy:Sun21Apr19-Sat27Apr19"=> [], "Energy:Sun28Apr19-Sat04May19"=> []},
    chart1_type: :column,
    chart1_subtype: nil,
    y_axis_label: "£",
    config_name: :teachers_landing_page_gas,
    configuration: {}
  }

describe ChartDataValues do

  it 'handles labels properly' do
    chart_data_values = ChartDataValues.new(EXAMPLE_CONFIG, :teachers_landing_page_gas).process
    expect(chart_data_values.series_data.first[:name]).to eq "Sun 21/04/2019 - Sat 27/04/2019"
    expect(chart_data_values.series_data.second[:name]).to eq "Sun 28/04/2019 - Sat 04/05/2019"
    expect(chart_data_values.x_axis_categories).to eq ["S", "M", "T", "W", "T", "F", "S"]
  end

  it 'sets the teacher-style colours for gas dashboard and pupil analysis charts' do
    chart_data_values = ChartDataValues.new(EXAMPLE_CONFIG, :calendar_picker_gas_day_example_comparison_chart).process
    expect(chart_data_values.series_data.first[:color]).to eq ChartDataValues::DARK_GAS
  end

  it 'sets the teacher-style colours for electricity dashboard and pupil analysis charts' do
    chart_data_values = ChartDataValues.new(EXAMPLE_CONFIG, :calendar_picker_electricity_day_example_comparison_chart).process
    expect(chart_data_values.series_data.first[:color]).to eq ChartDataValues::DARK_ELECTRICITY
  end

  it 'sets the teacher-style colours for electricity line charts' do
    chart_data_values = ChartDataValues.new(EXAMPLE_CONFIG.merge(chart1_type: :line), :calendar_picker_electricity_day_example_comparison_chart).process
    expect(chart_data_values.series_data.first[:color]).to eq ChartDataValues::DARK_ELECTRICITY
  end

  it 'sets the teacher-style colours for gas line charts' do
    chart_data_values = ChartDataValues.new(EXAMPLE_CONFIG.merge(chart1_type: :line), :calendar_picker_gas_day_example_comparison_chart).process
    expect(chart_data_values.series_data.first[:color]).to eq ChartDataValues::DARK_GAS
  end

  it 'works out the best colour when label matches' do
    label = ChartDataValues::COLOUR_HASH.keys.first
    colour = ChartDataValues::COLOUR_HASH[label]

    expect(ChartDataValues.new({}, :a).work_out_best_colour(label)).to be colour
  end

  it 'works out the best colour when label includes one of the keys' do
    colour_key = ChartDataValues::COLOUR_HASH.keys.first
    label = "AB#{colour_key}C"
    colour = ChartDataValues::COLOUR_HASH[colour_key]


    expect(ChartDataValues.new({}, :a).work_out_best_colour(label)).to be colour
  end

  it 'does not re-use included colours' do
    colour_key = ChartDataValues::COLOUR_HASH.keys.first
    label = "AB#{colour_key}C"
    colour = ChartDataValues::COLOUR_HASH[colour_key]


    cdv = ChartDataValues.new({}, :a)
    expect(cdv.work_out_best_colour(label)).to be colour
    expect(cdv.work_out_best_colour(label)).to be nil
  end
end

