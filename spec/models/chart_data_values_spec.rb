require 'rails_helper'

describe ChartDataValues do

  let(:chart) { :management_dashboard_group_by_week_electricity }
  let(:chart_type)  { :column }
  let(:x_axis_ranges) { [[Date.parse('Sun, 28 Apr 2019'), Date.parse('Sun, 28 Apr 2019')]] }
  let(:config) {
    {
      title: "Comparison of last 2 weeks gas consumption - adjusted for outside temperature £7.70",
      x_axis: %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday],
      x_axis_ranges: x_axis_ranges,
      x_data: { "Energy:Sun21Apr19-Sat27Apr19" => [], "Energy:Sun28Apr19-Sat04May19" => [] },
      chart1_type: chart_type,
      chart1_subtype: nil,
      y_axis_label: "£",
      config_name: chart,
      configuration: {}
    }
  }
  let(:transformations) { [] }
  let(:allowed_operations) { {} }
  let(:drilldown_available) { false }
  let(:parent_timescale_description) { nil }
  let(:y1_axis_choices) { [] }

  let(:chart_data_values)  { ChartDataValues.new(config, chart, transformations: transformations, allowed_operations: allowed_operations, drilldown_available: drilldown_available, parent_timescale_description: parent_timescale_description, y1_axis_choices: y1_axis_choices).process }

  it 'handles labels properly' do
    expect(chart_data_values.series_data.first[:name]).to eq "Sun 21 Apr 19 - Sat 27 Apr 19"
    expect(chart_data_values.series_data.second[:name]).to eq "Sun 28 Apr 19 - Sat 04 May 19"
    expect(chart_data_values.x_axis_categories).to eq %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]
  end

  context 'when setting colours' do
    context 'for gas dashboard and pupil analysis charts' do
      let(:chart) { :calendar_picker_gas_day_example_comparison_chart }
      it 'sets the right colours' do
        expect(chart_data_values.series_data.first[:color]).to eq ChartDataValues::DARK_GAS
      end
    end
    context 'for electricity dashboard and pupil analysis charts' do
      let(:chart) { :calendar_picker_electricity_day_example_comparison_chart }
      it 'sets the right colours' do
        expect(chart_data_values.series_data.first[:color]).to eq ChartDataValues::DARK_ELECTRICITY
      end
    end
    context 'for electricity line charts' do
      let(:chart) { :calendar_picker_electricity_day_example_comparison_chart }
      let(:chart_type)  { :line }
      it 'sets the right colours' do
        expect(chart_data_values.series_data.first[:color]).to eq ChartDataValues::DARK_ELECTRICITY
      end
    end
    context 'for gas line charts' do
      let(:chart) { :calendar_picker_gas_day_example_comparison_chart }
      let(:chart_type)  { :line }
      it 'sets the right colours' do
        expect(chart_data_values.series_data.first[:color]).to eq ChartDataValues::DARK_GAS
      end
    end
    it 'works out the best colour when label matches' do
      label = chart_data_values.colour_lookup.keys.first
      colour = chart_data_values.colour_lookup[label]
      expect(ChartDataValues.new({}, :a).work_out_best_colour(label)).to eq(colour)
    end
    it 'works out the best colour when label includes one of the keys' do
      colour_key = chart_data_values.colour_lookup.keys.first
      label = "AB#{colour_key}C"
      colour = chart_data_values.colour_lookup[colour_key]
      expect(ChartDataValues.new({}, :a).work_out_best_colour(label)).to eq(colour)
    end
    it 'does not re-use included colours' do
      colour_key = chart_data_values.colour_lookup.keys.first
      label = "AB#{colour_key}C"
      colour = chart_data_values.colour_lookup[colour_key]
      cdv = ChartDataValues.new({}, :a)
      expect(cdv.work_out_best_colour(label)).to eq(colour)
      expect(cdv.work_out_best_colour(label)).to eq(nil)
    end
  end

  context 'with limited y-axis choices' do
    let(:y1_axis_choices) { [:kwh, :£] }
    let(:chart_type) { :line }
    let(:chart) { :calendar_picker_gas_day_example_comparison_chart }
    it 'sets the choices' do
      expect(chart_data_values.y1_axis_choices).to eql y1_axis_choices
    end
  end

  describe '#series_translation_key_lookup' do
    it 'returns a hash matching series text keys to translation key values' do
      expect(chart_data_values.series_translation_key_lookup).to eq(
        { "Degree Days" => "degree_days", "Temperature" => "temperature", "School Day Closed" => "school_day_closed", "School Day Open" => "school_day_open", "Holiday" => "holiday", "Weekend" => "weekend", "Storage heater charge (school day)" => "storage_heater_charge", "Hot Water Usage" => "useful_hot_water_usage", "Wasted Hot Water Usage" => "wasted_hot_water_usage", "solar pv (consumed onsite)" => "solar_pv", "Solar Irradiance" => "solar_irradiance", "Carbon Intensity of Electricity Grid (kg/kWh)" => "gridcarbon", "Carbon Intensity of Gas (kg/kWh)" => "gascarbon", "Heating on in cold weather" => "heating_day", "Hot Water (& Kitchen)" => "non_heating_day", "Heating on in warm weather" => "heating_day_warm_weather", "electricity" => "electricity", "gas" => "gas", "storage heaters" => "storage_heaters", "Predicted Heat" => "predicted_heat", "Target degree days" => "target_degree_days", "CUSUM" => "cusum", "BASELOAD" => "baseload", "Peak (kW)" => "peak_kw", "Heating On School Days" => "school_day_heating", "Heating On Holidays" => "holiday_heating", "Heating On Weekends" => "weekend_heating", "Hot water/kitchen only On School Days" => "school_day_hot_water_kitchen", "Hot water/kitchen only On Holidays" => "holiday_hot_water_kitchen", "Hot water/kitchen only On Weekends" => "weekend_hot_water_kitchen", "Boiler Off" => "boiler_off", "Energy" => "none", "Exemplar School" => "exemplar_school", "Benchmark (Good) School" => "benchmark_school", "Community" => "community", "Community Baseload" => "community_baseload", "Electricity consumed from solar pv" => "electricity_consumed_from_solar_pv", "Exported solar electricity (not consumed onsite)" => "exported_solar_electricity", "Electricity consumed from mains" => "electricity_consumed_from_mains"}
      )
    end

    it 'expects there to be translation text for every series translation key' do
      expect(I18n.t('analytics.series_data_manager.series_name').keys.map(&:to_s).sort).to eq(chart_data_values.series_translation_key_lookup.values.sort)
    end
  end

  describe '#translated_series_item_for' do
    it 'returns a translation key for a series given string' do
      I18n.t('analytics.series_data_manager.series_name').each do |key, value|
        expect(chart_data_values.translated_series_item_for(I18n.t("analytics.series_data_manager.series_name.#{key}"))).to eq(value)
      end
    end

    it 'returns the series string if no translation is found' do
      expect(chart_data_values.translated_series_item_for('This series item is not translated')).to eq('This series item is not translated')
    end
  end

  describe '#wrap_label_as_html' do
    it 'adds line breaks tags to break up a given label and wraps it in a span' do
      expect(chart_data_values.send(:wrap_label_as_html, 'Degree Days')).to eq('<span>Degree<br />Days</span>')
    end
  end

  describe '#label_point_and_max_for' do
    it 'returns the label, point format, and max value (if needed) for a given y2 data title' do
      expect(chart_data_values.send(:label_point_and_max_for, Series::Temperature::TEMPERATURE)).to eq(['°C', '{point.y:.2f} °C',])
      expect(chart_data_values.send(:label_point_and_max_for, 'Temperature')).to eq(['°C', '{point.y:.2f} °C',])
      expect(chart_data_values.send(:label_point_and_max_for, Series::DegreeDays::DEGREEDAYS)).to eq(["<span>Degree<br />Days</span>", "{point.y:.2f} Degree Days"])
      expect(chart_data_values.send(:label_point_and_max_for, 'Degree Days')).to eq(["<span>Degree<br />Days</span>", "{point.y:.2f} Degree Days"])
      expect(chart_data_values.send(:label_point_and_max_for, Series::GridCarbon::GRIDCARBON)).to eq(["kg/kWh", "{point.y:.2f} kg/kWh", 0.5])
      expect(chart_data_values.send(:label_point_and_max_for, 'Carbon Intensity of Electricity Grid (kg/kWh)')).to eq(["kg/kWh", "{point.y:.2f} kg/kWh", 0.5])
      expect(chart_data_values.send(:label_point_and_max_for, Series::GasCarbon::GASCARBON)).to eq(['kg/kWh', '{point.y:.2f} kg/kWh', 0.5])
      expect(chart_data_values.send(:label_point_and_max_for, 'Carbon Intensity of Gas (kg/kWh)')).to eq(['kg/kWh', '{point.y:.2f} kg/kWh', 0.5])
      expect(chart_data_values.send(:label_point_and_max_for, 'Carbon Intensity')).to eq(['kg/kWh', '{point.y:.2f} kg/kWh', 0.5])
      expect(chart_data_values.send(:label_point_and_max_for, 'Carbon')).to eq(['kWh', '{point.y:.2f} kWh',])
      expect(chart_data_values.send(:label_point_and_max_for, chart_data_values.translated_series_item_for(Series::Irradiance::IRRADIANCE))).to eq(['<span>Brightness<br>of sunshine<br>W/m2</span>', "{point.y:.2f} W/m2"])
      expect(chart_data_values.send(:label_point_and_max_for, 'Solar Irradiance')).to eq(['<span>Brightness<br>of sunshine<br>W/m2</span>', "{point.y:.2f} W/m2"])
      expect(chart_data_values.send(:label_point_and_max_for, 'Solar')).to eq(['<span>Brightness<br>of sunshine<br>W/m2</span>', "{point.y:.2f} W/m2"])
      expect(chart_data_values.send(:label_point_and_max_for, 'Rating')).to eq(['Rating'])
    end
  end

  describe '#colour_lookup' do
    it 'returns a hash with colours assigned to chart series names' do
      expect(chart_data_values.colour_lookup).to eq(
        {"Degree Days" => "#232b49", "Temperature" => "#232b49", "School Day Closed" => "#3bc0f0", "School Day Open" => "#5cb85c", "Holiday" => "#ff4500", "Weekend" => "#ffac21", "Heating on in cold weather" => "#3bc0f0", "Hot Water (& Kitchen)" => "#5cb85c", "Hot Water Usage" => "#3bc0f0", "Wasted Hot Water Usage" => "#ff4500", "Solar PV (consumed onsite)" => "#ffac21", "Electricity" => "#007EFF", "Gas" => "#FF8438", "Storage heaters" => "#501e74", "£" => "#232B49", "Electricity consumed from solar pv" => "#5cb85c", "translation missing: en.analytics.series_data_manager.series_name.Electricity consumed from mains" => "#007EFF", "translation missing: en.analytics.series_data_manager.series_name.Exported solar electricity (not consumed onsite)" => "#FCB43A", "Solar irradiance (brightness of sunshine)" => "#FFB138", "Rating" => "#232b49"}
      )
    end
  end

  describe '#trendline?' do
    it 'returns true if the data type starts with trendline' do
      expect(chart_data_values.send(:trendline?, :"trendline_heating_occupied_all_days =-138.9T + 2684, r2 = 0.64, n=138")).to be_truthy
      expect(chart_data_values.send(:trendline?, "trendline_heating_occupied_all_days =-138.9T + 2684, r2 = 0.64, n=138")).to be_truthy
      expect(chart_data_values.send(:trendline?, :"Trendline heating occupied all days =-138.9T + 2684, r2 = 0.64, n=138")).to be_truthy
      expect(chart_data_values.send(:trendline?, "Trendline heating occupied all days =-138.9T + 2684, r2 = 0.64, n=138")).to be_truthy
      expect(chart_data_values.send(:trendline?, :not_a_trendline)).not_to be_truthy
      expect(chart_data_values.send(:trendline?, "not a trendline either")).not_to be_truthy
    end
  end

  describe '#reduced_trendline_series_data_for' do
    it 'merges elements of the x_axis with corresponding data elements replacing all but the maximum and minimum values with nil' do
      # Trendline data needs to be reduced to maximum and minimum values only to reliably plot
      # a non-breaking straight line between two points.
      expect(chart_data_values.send(:reduced_trendline_series_data_for, [0,1,2,3,4,5,6])).to eq([["Sunday", 0], ["Monday", nil], ["Tuesday", nil], ["Wednesday", nil], ["Thursday", nil], ["Friday", nil], ["Saturday", 6]])
      expect(chart_data_values.send(:reduced_trendline_series_data_for, [0,6,2,-1,4,5,3])).to eq([["Sunday", nil], ["Monday", 6], ["Tuesday", nil], ["Wednesday", -1], ["Thursday", nil], ["Friday", nil], ["Saturday", nil]])
    end
  end

  describe '#scatter_series_data_for' do
    it 'merges elements of the x_axis with corresponding data elements' do
      expect(chart_data_values.send(:scatter_series_data_for, [0,1,2,3,4,5,6])).to eq([["Sunday", 0], ["Monday", 1], ["Tuesday", 2], ["Wednesday", 3], ["Thursday", 4], ["Friday", 5], ["Saturday", 6]])
      expect(chart_data_values.send(:scatter_series_data_for, [6,2,5,4,3,0,1])).to eq([["Sunday", 6], ["Monday", 2], ["Tuesday", 5], ["Wednesday", 4], ["Thursday", 3], ["Friday", 0], ["Saturday", 1]])
    end
  end

  context 'sub-title dates' do
    let(:x_axis_ranges) { [[Date.new(2023,1,31), Date.new(2023,2,4)]] }

    context 'with no transformations' do
      it 'includes the chart date range' do
        expect(chart_data_values.subtitle_start_date).to eq "31 Jan 2023"
        expect(chart_data_values.subtitle_end_date).to eq "04 Feb 2023"
      end
    end
    context 'with drill down' do
      let(:transformations) { [[:drilldown, 293]] }
      it 'does not include the chart date range' do
        expect(chart_data_values.subtitle_start_date).to be_nil
        expect(chart_data_values.subtitle_end_date).to be_nil
      end
    end
    context 'with move then drill down' do
      let(:transformations) { [[:move, -2], [:drilldown, 141]] }
      it 'does not include the chart date range' do
        expect(chart_data_values.subtitle_start_date).to be_nil
        expect(chart_data_values.subtitle_end_date).to be_nil
      end
    end
    context 'with drill down then move' do
      let(:transformations) { [[:drilldown, 1], [:move, -1]] }
      it 'does not include the chart date range' do
        expect(chart_data_values.subtitle_start_date).to be_nil
        expect(chart_data_values.subtitle_end_date).to be_nil
      end
    end
    context 'with move back' do
      let(:transformations) { [[:move, 1]] }
      it 'includes the chart date range' do
        expect(chart_data_values.subtitle_start_date).to eq "31 Jan 2023"
        expect(chart_data_values.subtitle_end_date).to eq "04 Feb 2023"
      end
    end
  end
end
