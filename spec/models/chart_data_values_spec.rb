require 'rails_helper'

EXAMPLE_CONFIG = {
    title: "Comparison of last 2 weeks gas consumption - adjusted for outside temperature £7.70",
    x_axis: %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday],
    x_axis_ranges: [[Date.parse('Sun, 28 Apr 2019'), Date.parse('Sun, 28 Apr 2019')]],
    x_data: { "Energy:Sun21Apr19-Sat27Apr19" => [], "Energy:Sun28Apr19-Sat04May19" => [] },
    chart1_type: :column,
    chart1_subtype: nil,
    y_axis_label: "£",
    config_name: :teachers_landing_page_gas,
    configuration: {}
  }.freeze

describe ChartDataValues do
  it 'handles labels properly' do
    chart_data_values = ChartDataValues.new(EXAMPLE_CONFIG, :teachers_landing_page_gas).process
    expect(chart_data_values.series_data.first[:name]).to eq "Sun 21 Apr 19 - Sat 27 Apr 19"
    expect(chart_data_values.series_data.second[:name]).to eq "Sun 28 Apr 19 - Sat 04 May 19"
    expect(chart_data_values.x_axis_categories).to eq %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]
  end

  it 'sets the colours for gas dashboard and pupil analysis charts' do
    chart_data_values = ChartDataValues.new(EXAMPLE_CONFIG, :calendar_picker_gas_day_example_comparison_chart).process
    expect(chart_data_values.series_data.first[:color]).to eq ChartDataValues::DARK_GAS
  end

  it 'sets the colours for electricity dashboard and pupil analysis charts' do
    chart_data_values = ChartDataValues.new(EXAMPLE_CONFIG, :calendar_picker_electricity_day_example_comparison_chart).process
    expect(chart_data_values.series_data.first[:color]).to eq ChartDataValues::DARK_ELECTRICITY
  end

  it 'sets the colours for electricity line charts' do
    chart_data_values = ChartDataValues.new(EXAMPLE_CONFIG.merge(chart1_type: :line), :calendar_picker_electricity_day_example_comparison_chart).process
    expect(chart_data_values.series_data.first[:color]).to eq ChartDataValues::DARK_ELECTRICITY
  end

  it 'sets the colours for gas line charts' do
    chart_data_values = ChartDataValues.new(EXAMPLE_CONFIG.merge(chart1_type: :line), :calendar_picker_gas_day_example_comparison_chart).process
    expect(chart_data_values.series_data.first[:color]).to eq ChartDataValues::DARK_GAS
  end

  it 'works out the best colour when label matches' do
    chart_data_values = ChartDataValues.new(EXAMPLE_CONFIG, :teachers_landing_page_gas).process
    label = chart_data_values.send(:colour_lookup).keys.first
    colour = chart_data_values.send(:colour_lookup)[label]

    expect(ChartDataValues.new({}, :a).work_out_best_colour(label)).to eq(colour)
  end

  it 'works out the best colour when label includes one of the keys' do
    chart_data_values = ChartDataValues.new(EXAMPLE_CONFIG, :teachers_landing_page_gas).process
    colour_key = chart_data_values.send(:colour_lookup).keys.first
    label = "AB#{colour_key}C"
    colour = chart_data_values.send(:colour_lookup)[colour_key]
    expect(ChartDataValues.new({}, :a).work_out_best_colour(label)).to eq(colour)
  end

  it 'does not re-use included colours' do
    chart_data_values = ChartDataValues.new(EXAMPLE_CONFIG, :teachers_landing_page_gas).process
    colour_key = chart_data_values.send(:colour_lookup).keys.first
    label = "AB#{colour_key}C"
    colour = chart_data_values.send(:colour_lookup)[colour_key]
    cdv = ChartDataValues.new({}, :a)
    expect(cdv.work_out_best_colour(label)).to eq(colour)
    expect(cdv.work_out_best_colour(label)).to eq(nil)
  end

  it 'includes y-axis choices' do
    y1_axis_choices = [:kwh, :£]
    chart_data_values = ChartDataValues.new(EXAMPLE_CONFIG.merge(chart1_type: :line), :calendar_picker_gas_day_example_comparison_chart, y1_axis_choices: y1_axis_choices).process
    expect(chart_data_values.y1_axis_choices).to eql y1_axis_choices
  end

  describe '#series_translation_key_lookup' do
    chart_data_values = ChartDataValues.new(EXAMPLE_CONFIG, :teachers_landing_page_gas).process

    it 'returns a hash matching series text keys to translation key values' do
      expect(chart_data_values.series_translation_key_lookup).to eq(
        {
          "Degree Days" => "degree_days",
          "Temperature" => "temperature",
          "School Day Closed" => "school_day_closed",
          "School Day Open" => "school_day_open",
          "Holiday" => "holiday",
          "Weekend" => "weekend",
          "Storage heater charge (school day)" => "storage_heater_charge",
          "Hot Water Usage" => "useful_hot_water_usage",
          "Wasted Hot Water Usage" => "wasted_hot_water_usage",
          "solar pv (consumed onsite)" => "solar_pv",
          "Solar Irradiance" => "solar_irradiance",
          "Carbon Intensity of Electricity Grid (kg/kWh)" => "gridcarbon",
          "Carbon Intensity of Gas (kg/kWh)" => "gascarbon",
          "Heating on in cold weather" => "heating_day",
          "Hot Water (& Kitchen)" => "non_heating_day",
          "Heating on in warm weather" => "heating_day_warm_weather",
          "electricity" => "electricity",
          "gas" => "gas",
          "storage heaters" => "storage_heaters",
          "Predicted Heat" => "predicted_heat",
          "Target degree days" => "target_degree_days",
          "CUSUM" => "cusum",
          "BASELOAD" => "baseload",
          "Peak (kW)" => "peak_kw",
          "Heating On School Days" => "school_day_heating",
          "Heating On Holidays" => "holiday_heating",
          "Heating On Weekends" => "weekend_heating",
          "Hot water/kitchen only On School Days" => "school_day_hot_water_kitchen",
          "Hot water/kitchen only On Holidays" => "holiday_hot_water_kitchen",
          "Hot water/kitchen only On Weekends" => "weekend_hot_water_kitchen",
          "Boiler Off" => "boiler_off",
          "Energy" => "none",
          "Exemplar School" => "exemplar_school",
          "Benchmark (Good) School" => "benchmark_school"
        }
      )
    end

    it 'expects there to be translation text for every series translation key' do
      expect(I18n.t('analytics.series_data_manager.series_name').keys.map(&:to_s).sort).to eq(chart_data_values.series_translation_key_lookup.values.sort)
    end
  end

  describe '#translated_series_item_for' do
    chart_data_values = ChartDataValues.new(EXAMPLE_CONFIG, :teachers_landing_page_gas).process

    it 'returns a translation key for a series given string' do
      I18n.t('analytics.series_data_manager.series_name').each do |key, value|
        expect(chart_data_values.translated_series_item_for(I18n.t("analytics.series_data_manager.series_name.#{key}"))).to eq(value)
      end
    end

    it 'returns the series string if no translation is found' do
      expect(chart_data_values.translated_series_item_for('This series item is not translated')).to eq('This series item is not translated')
    end
  end
end
