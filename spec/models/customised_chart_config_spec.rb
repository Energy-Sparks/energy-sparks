require 'rails_helper'

describe CustomisedChartConfig do

  it 'preserves unrelated configuration' do
    expect(
      CustomisedChartConfig.new({title: 'Mega analysis'}).customise({test: :co2})
    ).to eq(
      {title: 'Mega analysis'}
    )
  end

  describe 'yaxis_units' do

    it 'allows y_axis override of chart configs that are in kwh' do
      expect(
        CustomisedChartConfig.new({yaxis_units: :kwh}).customise({y_axis_units: :co2})
      ).to eq( {yaxis_units: :co2})
    end

    it 'swaps gp_pounds for £' do
      expect(
        CustomisedChartConfig.new({yaxis_units: :kwh}).customise({y_axis_units: :gb_pounds})
      ).to eq( {yaxis_units: :£})
    end

    it 'does not change the units if not provided' do
      expect(
        CustomisedChartConfig.new({yaxis_units: :kwh}).customise({})
      ).to eq( {yaxis_units: :kwh} )
      expect(
        CustomisedChartConfig.new({yaxis_units: :kwh}).customise({yaxis_units: nil})
      ).to eq( {yaxis_units: :kwh} )
    end

    it 'checks for valid options' do
      allow_any_instance_of(ChartYAxisManipulation).to receive(:y1_axis_choices).and_return([:co2])
      expect(
        CustomisedChartConfig.new({yaxis_units: :co2}).customise({y_axis_units: :£})
      ).to eq( {yaxis_units: :co2})
    end
  end

  describe 'meter definition' do
    it 'converts the mpan_mprn to an integer' do
      expect(
        CustomisedChartConfig.new({}).customise({mpan_mprn: "12345"})
      ).to eq( {meter_definition: 12345} )
    end
  end

  describe 'series breakdown' do
    it 'converts the series_breakdown to a symbol' do
      expect(
        CustomisedChartConfig.new({}).customise({series_breakdown: 'none'})
      ).to eq( {series_breakdown: :none} )
    end
  end

  describe 'timescale' do
    it 'maps arrays of dateranges to the hash format' do
      expect(
        CustomisedChartConfig.new({}).customise({date_ranges: [(Date.new(2019, 10, 10)..Date.new(2019, 10, 16))]})
      ).to eq( {timescale: [{daterange: Date.new(2019, 10, 10)..Date.new(2019, 10, 16)}]} )
    end
  end

end
