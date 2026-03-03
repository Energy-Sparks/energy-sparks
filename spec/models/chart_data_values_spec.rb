require 'rails_helper'

describe ChartDataValues do
  let(:chart) { :management_dashboard_group_by_week_electricity }
  let(:chart_type)  { :column }
  let(:x_axis)      { %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday] }
  let(:x_axis_ranges) { [[Date.parse('Sun, 28 Apr 2019'), Date.parse('Sun, 28 Apr 2019')]] }
  let(:config) do
    {
      title: 'Comparison of last 2 weeks gas consumption - adjusted for outside temperature £7.70',
      x_axis: x_axis,
      x_axis_ranges: x_axis_ranges,
      x_data: { 'Energy:Sun21Apr19-Sat27Apr19' => [], 'Energy:Sun28Apr19-Sat04May19' => [] },
      chart1_type: chart_type,
      chart1_subtype: nil,
      y_axis_label: '£',
      config_name: chart,
      configuration: {}
    }
  end
  let(:transformations) { [] }
  let(:allowed_operations) { {} }
  let(:drilldown_available) { false }
  let(:parent_timescale_description) { nil }
  let(:y1_axis_choices) { [] }

  let(:chart_data_values) do
    ChartDataValues.new(config, chart, transformations: transformations, allowed_operations: allowed_operations, drilldown_available: drilldown_available, parent_timescale_description: parent_timescale_description, y1_axis_choices: y1_axis_choices).process
  end

  it 'handles labels properly' do
    expect(chart_data_values.series_data.first[:name]).to eq 'Sun 21 Apr 19 - Sat 27 Apr 19'
    expect(chart_data_values.series_data.second[:name]).to eq 'Sun 28 Apr 19 - Sat 04 May 19'
    expect(chart_data_values.x_axis_categories).to eq %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]
  end

  context 'with scatter chart' do
    let(:chart_type)  { :scatter }
    let(:x_axis)      { [0.1, 0.2, 0.3]}

    it 'doesnt translate series labels' do
      first_series = chart_data_values.series_data[0]
      first_item = first_series[:data].first
      # confirm that series data are numbers, not strings
      expect(first_item[0]).to be_a Float
    end
  end

  context 'when setting colours' do
    context 'when adding colours to column charts' do
      subject(:series) { chart_data_values.series_data.first }

      context 'for gas dashboard and pupil analysis charts' do
        let(:chart) { :calendar_picker_gas_day_example_comparison_chart }

        it 'sets the right colours' do
          expect(series[:color]).to eq Colours.chart_gas_dark
        end
      end

      context 'for electricity dashboard and pupil analysis charts' do
        let(:chart) { :calendar_picker_electricity_day_example_comparison_chart }

        it 'sets the right colours' do
          expect(series[:color]).to eq Colours.chart_electric_dark
        end
      end

      context 'for electricity line charts' do
        let(:chart) { :calendar_picker_electricity_day_example_comparison_chart }
        let(:chart_type) { :line }

        it 'sets the right colours' do
          expect(series[:color]).to eq Colours.chart_electric_dark
        end
      end

      context 'for gas line charts' do
        let(:chart) { :calendar_picker_gas_day_example_comparison_chart }
        let(:chart_type) { :line }

        it 'sets the right colours' do
          expect(series[:color]).to eq Colours.chart_gas_dark
        end
      end
    end

    context 'when adding colours to other charts' do
      subject(:colour) do
        ChartDataValues.new({}, :a).work_out_best_colour(label)
      end

      context 'when there is a label match' do
        let(:label) { chart_data_values.colour_lookup.keys.first }
        let(:expected_colour) { chart_data_values.colour_lookup[label] }

        it 'uses the label colour' do
          expect(colour).to eq(expected_colour)
        end
      end

      context 'when there is a match to a key' do
        let(:label) { "AB#{chart_data_values.colour_lookup.keys.first}C" }
        let(:expected_colour) { chart_data_values.colour_lookup[chart_data_values.colour_lookup.keys.first] }

        it 'uses the label colour' do
          expect(colour).to eq(expected_colour)
        end

        context 'when there are multiple series matching a colour' do
          it 'does not re-use included colours' do
            cdv = ChartDataValues.new({}, :a)
            expect(cdv.work_out_best_colour(label)).to eq(expected_colour)
            expect(cdv.work_out_best_colour(label)).to eq(nil)
          end
        end
      end

      context 'when fuel type provided' do
        subject(:colour) do
          ChartDataValues.new(config, chart, fuel_type: :electricity).work_out_best_colour(label)
        end

        context 'when there is a label match' do
          let(:label) { I18n.t('analytics.series_data_manager.series_name.gas') }

          it 'uses the label colour' do
            expect(colour).to eq(Colours.chart_gas)
          end
        end

        context 'when there is no other match' do
          let(:label) { 'Testing' }

          it 'uses the fuel type colour' do
            expect(colour).to eq(Colours.chart_electric)
          end
        end
      end
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
        { 'Degree Days' => 'degree_days', 'Temperature' => 'temperature', 'School Day Closed' => 'school_day_closed', 'School Day Open' => 'school_day_open', 'Holiday' => 'holiday', 'Weekend' => 'weekend', 'Storage heater charge (school day)' => 'storage_heater_charge', 'Hot Water Usage' => 'useful_hot_water_usage', 'Wasted Hot Water Usage' => 'wasted_hot_water_usage', 'solar pv (consumed onsite)' => 'solar_pv', 'Solar Irradiance' => 'solar_irradiance', 'Carbon Intensity of Electricity Grid (kg/kWh)' => 'gridcarbon', 'Carbon Intensity of Gas (kg/kWh)' => 'gascarbon', 'Heating on in cold weather' => 'heating_day', 'Hot Water (& Kitchen)' => 'non_heating_day', 'Heating on in warm weather' => 'heating_day_warm_weather', 'electricity' => 'electricity', 'gas' => 'gas', 'storage heaters' => 'storage_heaters', 'Predicted Heat' => 'predicted_heat', 'Target degree days' => 'target_degree_days', 'CUSUM' => 'cusum', 'BASELOAD' => 'baseload', 'Peak (kW)' => 'peak_kw', 'Heating On School Days' => 'school_day_heating', 'Heating On Holidays' => 'holiday_heating', 'Heating On Weekends' => 'weekend_heating', 'Hot water/kitchen only On School Days' => 'school_day_hot_water_kitchen', 'Hot water/kitchen only On Holidays' => 'holiday_hot_water_kitchen', 'Hot water/kitchen only On Weekends' => 'weekend_hot_water_kitchen', 'Boiler Off' => 'boiler_off', 'Energy' => 'none', 'Exemplar School' => 'exemplar_school', 'Benchmark (Good) School' => 'benchmark_school', 'Community' => 'community', 'Community Baseload' => 'community_baseload', 'Electricity consumed from solar pv' => 'electricity_consumed_from_solar_pv', 'Exported solar electricity (not consumed onsite)' => 'exported_solar_electricity', 'Electricity consumed from mains' => 'electricity_consumed_from_mains' }
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
      expect(chart_data_values.send(:label_point_and_max_for, Series::DegreeDays::DEGREEDAYS)).to eq(['<span>Degree<br />Days</span>', '{point.y:.2f} Degree Days'])
      expect(chart_data_values.send(:label_point_and_max_for, 'Degree Days')).to eq(['<span>Degree<br />Days</span>', '{point.y:.2f} Degree Days'])
      expect(chart_data_values.send(:label_point_and_max_for, Series::GridCarbon::GRIDCARBON)).to eq(['kg/kWh', '{point.y:.2f} kg/kWh', 0.5])
      expect(chart_data_values.send(:label_point_and_max_for, 'Carbon Intensity of Electricity Grid (kg/kWh)')).to eq(['kg/kWh', '{point.y:.2f} kg/kWh', 0.5])
      expect(chart_data_values.send(:label_point_and_max_for, Series::GasCarbon::GASCARBON)).to eq(['kg/kWh', '{point.y:.2f} kg/kWh', 0.5])
      expect(chart_data_values.send(:label_point_and_max_for, 'Carbon Intensity of Gas (kg/kWh)')).to eq(['kg/kWh', '{point.y:.2f} kg/kWh', 0.5])
      expect(chart_data_values.send(:label_point_and_max_for, 'Carbon Intensity')).to eq(['kg/kWh', '{point.y:.2f} kg/kWh', 0.5])
      expect(chart_data_values.send(:label_point_and_max_for, 'Carbon')).to eq(['kWh', '{point.y:.2f} kWh',])
      expect(chart_data_values.send(:label_point_and_max_for, chart_data_values.translated_series_item_for(Series::Irradiance::IRRADIANCE))).to eq(['<span>Brightness<br>of sunshine<br>W/m2</span>', '{point.y:.2f} W/m2'])
      expect(chart_data_values.send(:label_point_and_max_for, 'Solar Irradiance')).to eq(['<span>Brightness<br>of sunshine<br>W/m2</span>', '{point.y:.2f} W/m2'])
      expect(chart_data_values.send(:label_point_and_max_for, 'Solar')).to eq(['<span>Brightness<br>of sunshine<br>W/m2</span>', '{point.y:.2f} W/m2'])
      expect(chart_data_values.send(:label_point_and_max_for, 'Rating')).to eq(['Rating'])
    end
  end

  describe '#colour_lookup' do
    it 'returns a hash with colours assigned to chart series names' do
      expect(chart_data_values.colour_lookup).to eq(
        { 'Degree Days' => Colours.chart_degree_days,
          'Temperature' => Colours.chart_temperature,
          'School Day Closed' => Colours.chart_school_day_closed,
          'School Day Open' => Colours.chart_school_day_open,
          'Holiday' => Colours.chart_holiday,
          'Weekend' => Colours.chart_weekend,
          'Heating on in colder weather' => Colours.chart_heating_day,
          'Hot Water (& Kitchen)' => Colours.chart_non_heating_day,
          'Hot Water Usage' => Colours.chart_useful_hot_water_usage,
          'Wasted Hot Water Usage' => Colours.chart_wasted_hot_water_usage,
          'Solar PV (consumed onsite)' => Colours.chart_solar_pv,
          'Electricity' => Colours.chart_electric,
          'Gas' => Colours.chart_gas,
          'Storage heaters' => Colours.chart_storage_heater,
          '£' => Colours.chart_gbp,
          'Electricity consumed from solar pv' => Colours.chart_electricity_consumed_from_solar_pv,
          'Electricity consumed from mains' => Colours.chart_electricity_consumed_from_mains,
          'Exported solar electricity (not consumed onsite)' => Colours.chart_exported_solar_electricity,
          'Solar irradiance (brightness of sunshine)' => Colours.chart_y2_solar_label,
          'Rating' => Colours.chart_y2_rating }
      )
    end
  end

  describe '#trendline?' do
    it 'returns true if the data type starts with trendline' do
      expect(chart_data_values.send(:trendline?, :"trendline_heating_occupied_all_days =-138.9T + 2684, r2 = 0.64, n=138")).to be_truthy
      expect(chart_data_values.send(:trendline?, 'trendline_heating_occupied_all_days =-138.9T + 2684, r2 = 0.64, n=138')).to be_truthy
      expect(chart_data_values.send(:trendline?, :"Trendline heating occupied all days =-138.9T + 2684, r2 = 0.64, n=138")).to be_truthy
      expect(chart_data_values.send(:trendline?, 'Trendline heating occupied all days =-138.9T + 2684, r2 = 0.64, n=138')).to be_truthy
      expect(chart_data_values.send(:trendline?, :not_a_trendline)).not_to be_truthy
      expect(chart_data_values.send(:trendline?, 'not a trendline either')).not_to be_truthy
    end
  end

  describe '#reduced_trendline_series_data_for' do
    it 'merges elements of the x_axis with corresponding data elements replacing all but the maximum and minimum values with nil' do
      # Trendline data needs to be reduced to maximum and minimum values only to reliably plot
      # a non-breaking straight line between two points.
      expect(chart_data_values.send(:reduced_trendline_series_data_for, [0, 1, 2, 3, 4, 5, 6])).to eq([['Sunday', 0], ['Monday', nil], ['Tuesday', nil], ['Wednesday', nil], ['Thursday', nil], ['Friday', nil], ['Saturday', 6]])
      expect(chart_data_values.send(:reduced_trendline_series_data_for, [0, 6, 2, -1, 4, 5, 3])).to eq([['Sunday', nil], ['Monday', 6], ['Tuesday', nil], ['Wednesday', -1], ['Thursday', nil], ['Friday', nil], ['Saturday', nil]])
    end
  end

  describe '#scatter_series_data_for' do
    it 'merges elements of the x_axis with corresponding data elements' do
      expect(chart_data_values.send(:scatter_series_data_for, [0, 1, 2, 3, 4, 5, 6])).to eq([['Sunday', 0], ['Monday', 1], ['Tuesday', 2], ['Wednesday', 3], ['Thursday', 4], ['Friday', 5], ['Saturday', 6]])
      expect(chart_data_values.send(:scatter_series_data_for, [6, 2, 5, 4, 3, 0, 1])).to eq([['Sunday', 6], ['Monday', 2], ['Tuesday', 5], ['Wednesday', 4], ['Thursday', 3], ['Friday', 0], ['Saturday', 1]])
    end
  end

  context 'sub-title dates' do
    let(:x_axis_ranges) { [[Date.new(2023, 1, 31), Date.new(2023, 2, 4)]] }

    context 'with no transformations' do
      it 'includes the chart date range' do
        expect(chart_data_values.subtitle_start_date).to eq '31 Jan 2023'
        expect(chart_data_values.subtitle_end_date).to eq '04 Feb 2023'
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
        expect(chart_data_values.subtitle_start_date).to eq '31 Jan 2023'
        expect(chart_data_values.subtitle_end_date).to eq '04 Feb 2023'
      end
    end
  end

  context 'with benchmark charts' do
    let(:chart) { :benchmark }
    let(:chart_type) { :bar }
    let(:x_axis) { ['09 Feb 2019 to 07 Feb 2020', '08 Feb 2020 to 05 Feb 2021', 'Exemplar School', 'Benchmark (Good) School'] }
    let(:x_axis_ranges) do
      [['Sat, 09 Feb 2019', 'Fri, 07 Feb 2020'],
       ['Sat, 08 Feb 2020', 'Fri, 05 Feb 2021'],
       ['Sat, 06 Feb 2021', 'Fri, 04 Feb 2022'],
       ['Sat, 05 Feb 2022', 'Fri, 03 Feb 2023']]
    end
    let(:x_data) do
      { 'electricity' => [77230.65592499996, 60319.60000000002, 32928.30656992425, 47040.43795703465],
        'gas' => [21031.15421717688, 19455.429877914285, 15151.625158016384, 16335.345873486414] }
    end
    let(:config) do
      {
        title: 'Annual Electricity and Gas Consumption Comparison with other schools in your region',
        x_axis: x_axis,
        x_axis_ranges: x_axis_ranges,
        x_data: x_data,
        chart1_type: chart_type,
        chart1_subtype: :stacked,
        y_axis_label: '£',
        config_name: :benchmark,
        configuration: { :name => 'Annual Electricity and Gas Consumption Comparison',
           :chart1_type => :bar,
           :chart1_subtype => :stacked,
           :meter_definition => :all,
           :x_axis => :year,
           :series_breakdown => :fuel,
           :yaxis_units => :£,
           :restrict_y1_axis => [:£, :co2],
           :yaxis_scaling => :none,
           :inject => :benchmark,
           :y_axis_label => '£',
           :min_combined_school_date => 'Sun, 13 Jan 2019',
           :max_combined_school_date => 'Fri, 03 Feb 2023' },
         name: :benchmark
      }
    end
    let(:transformations) { [] }
    let(:allowed_operations) { {} }
    let(:drilldown_available) { false }
    let(:parent_timescale_description) { nil }
    let(:y1_axis_choices) { [] }

    let(:chart_data_values)  { ChartDataValues.new(config, chart, transformations: transformations, allowed_operations: allowed_operations, drilldown_available: drilldown_available, parent_timescale_description: parent_timescale_description, y1_axis_choices: y1_axis_choices).process }

    let(:electricity_series) { chart_data_values.series_data.first }
    let(:gas_series) { chart_data_values.series_data.last }

    it 'has right series default colours' do
      expect(electricity_series[:name]).to eq 'Electricity'
      expect(electricity_series[:color]).to eq Colours.chart_electric_dark
      expect(gas_series[:name]).to eq 'Gas'
      expect(gas_series[:color]).to eq Colours.chart_gas_dark
    end

    it 'overrides colours for benchmark and exemplar schools' do
      electricity_data = electricity_series[:data]
      expect(electricity_data[0]).to be_within(0.1).of(77230.6)
      expect(electricity_data[1]).to be_within(0.1).of(60319.6)

      exemplar = electricity_data[2]
      expect(exemplar[:y]).to be_within(0.1).of(32928.3)
      expect(exemplar[:color]).to eq Colours.chart_electric_light

      benchmark = electricity_data[3]
      expect(benchmark[:y]).to be_within(0.1).of(47040.4)
      expect(benchmark[:color]).to eq Colours.chart_electric_middle

      gas_data = gas_series[:data]
      expect(gas_data[0]).to be_within(0.1).of(21031.1)
      expect(gas_data[1]).to be_within(0.1).of(19455.4)

      exemplar = gas_data[2]
      expect(exemplar[:y]).to be_within(0.1).of(15151.6)
      expect(exemplar[:color]).to eq Colours.chart_gas_light

      benchmark = gas_data[3]
      expect(benchmark[:y]).to be_within(0.1).of(16335.3)
      expect(benchmark[:color]).to eq Colours.chart_gas_middle
    end
  end
end
