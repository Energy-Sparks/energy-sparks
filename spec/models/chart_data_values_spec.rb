require 'rails_helper'

EXAMPLE_CONFIG =  {:title=>"Comparison of last 2 weeks gas consumption - adjusted for outside temperature £7.70",
     :x_axis=>["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
     :x_axis_ranges=>
      [[Date.parse('Sun, 28 Apr 2019'), Date.parse('Sun, 28 Apr 2019')],
       [Date.parse('Mon, 29 Apr 2019'), Date.parse('Mon, 29 Apr 2019')],
       [Date.parse('Tue, 30 Apr 2019'), Date.parse('Tue, 30 Apr 2019')],
       [Date.parse('Wed, 01 May 2019'), Date.parse('Wed, 01 May 2019')],
       [Date.parse('Thu, 02 May 2019'), Date.parse('Thu, 02 May 2019')],
       [Date.parse('Fri, 03 May 2019'), Date.parse('Fri, 03 May 2019')],
       [Date.parse('Sat, 04 May 2019'), Date.parse('Sat, 04 May 2019')]],
     :x_data=>
      {"Energy:Sun21Apr19-Sat27Apr19"=>
        [0.5158457215948721,
         0.5966522453073847,
         0.587648232140897,
         0.5565685218135552,
         0.771497344421226,
         0.5087912524926482,
         0.2295293139882585],
       "Energy:Sun28Apr19-Sat04May19"=>
        [0.023274620370757997,
         0.7044552823413212,
         0.7251563313277753,
         0.7035452275750285,
         0.8943034807250079,
         0.7077889214116395,
         0.178289507496204]},
     :chart1_type=>:column,
     :chart1_subtype=>nil,
     :y_axis_label=>"£",
     :config_name=>:teachers_landing_page_gas,
     :configuration=>
      {:name=>"Comparison of last 2 weeks gas consumption - adjusted for outside temperature",
       :chart1_type=>:column,
       :series_breakdown=>:none,
       :x_axis_reformat=>{:date=>"%A"},
       :timescale=>[{:workweek=>0}, {:workweek=>-1}],
       :x_axis=>:day,
       :meter_definition=>:allheat,
       :yaxis_units=>:£,
       :yaxis_scaling=>:none,
       :y2_axis=>nil,
       :adjust_by_temperature=>10.0,
       :min_combined_school_date=>Date.parse('Mon, 04 Oct 2010'),
       :max_combined_school_date=>Date.parse('Tue, 07 May 2019'),
       :y_axis_label=>"£"}
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
    expect(chart_data_values.series_data.first[:color]).to eq ChartDataValues::DARK_ELECTRICITY_LINE
  end

  it 'sets the teacher-style colours for gas line charts' do
    chart_data_values = ChartDataValues.new(EXAMPLE_CONFIG.merge(chart1_type: :line), :calendar_picker_gas_day_example_comparison_chart).process
    expect(chart_data_values.series_data.first[:color]).to eq ChartDataValues::DARK_GAS_LINE
  end
end

