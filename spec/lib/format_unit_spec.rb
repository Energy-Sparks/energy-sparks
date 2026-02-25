# frozen_string_literal: true

require 'rails_helper'

describe FormatUnit, :aggregate_failures do
  let!(:value) { 113.66216439927433 }

  context 'with ks2 formatting' do
    [
      { units: :£_0dp, expected: '&pound;114', medium: :html, type: String },
      { units: :£_0dp, expected: '£114',       medium: :text, type: String },
      { units: :£,     expected: '&pound;110', medium: :html, type: String },
      { units: :£,     expected: 113.66216439927433, medium: :raw,  type: Float }
    ].each do |config|
      it "formats value as #{config[:units]} to #{config[:medium]} as expected" do
        result = described_class.format(config[:units], value, config[:medium])
        expect(result).to eq config[:expected]
        expect(result.class).to eq config[:type]
      end
    end
  end

  context 'with benchmark formatting' do
    [
      { units: :£_0dp, expected: '&pound;114', medium: :html, type: String },
      { units: :£_0dp, expected: '£114',       medium: :text, type: String },
      { units: :£,     expected: '&pound;114', medium: :html, type: String },
      { units: :£,     expected: 113.66216439927433, medium: :raw,  type: Float }
    ].each do |config|
      it "formats value as #{config[:units]} to #{config[:medium]} as expected" do
        result = described_class.format(config[:units], value, config[:medium], false, false, :benchmark)
        expect(result).to eq config[:expected]
        expect(result.class).to eq config[:type]
      end
    end
  end

  context 'with energy expert formatting' do
    [
      { units: :£_0dp, expected: '&pound;114', medium: :html, type: String },
      { units: :£_0dp, expected: '£114',       medium: :text, type: String },
      { units: :£,     expected: '&pound;113.6621644', medium: :html, type: String },
      { units: :£,     expected: 113.66216439927433, medium: :raw, type: Float }
    ].each do |config|
      it "formats value as #{config[:units]} to #{config[:medium]} as expected" do
        result = described_class.format(config[:units], value, config[:medium], false, false, :energy_expert)
        expect(result).to eq config[:expected]
        expect(result.class).to eq config[:type]
      end
    end
  end

  context "with 'to pence' formatting" do
    [
      { units: :£_0dp, expected: '&pound;114', medium: :html, type: String },
      { units: :£_0dp, expected: '£114',       medium: :text, type: String },
      { units: :£,     expected: '&pound;113.66', medium: :html, type: String },
      { units: :£,     expected: 113.66216439927433, medium: :raw, type: Float }
    ].each do |config|
      it "formats value as #{config[:units]} to #{config[:medium]} as expected" do
        result = described_class.format(config[:units], value, config[:medium], false, false, :to_pence)
        expect(result).to eq config[:expected]
        expect(result.class).to eq config[:type]
      end
    end
  end

  context 'when percentage formatting' do
    context 'with :percent' do
      it 'formats correctly' do
        expect(described_class.format(:percent, 0.37019427511151964)).to eq('37%')
        expect(described_class.format(:percent, 0.37019427511151964, :text)).to eq('37%')
        expect(described_class.format(:percent, 0.37019427511151964, :html)).to eq('37&percnt;')
      end
    end

    context 'with :percent_0dp' do
      it 'formats correctly' do
        expect(described_class.format(:percent_0dp, 0.37119427511151964)).to eq('37%')
        expect(described_class.format(:percent_0dp, 0.37119427511151964, :text)).to eq('37%')
        expect(described_class.format(:percent_0dp, 0.37019427511151964, :html)).to eq('37&percnt;')
      end
    end

    context 'with :relative_percent' do
      it 'formats correctly' do
        expect(described_class.format(:relative_percent, -0.1188911792177762)).to eq('-12%')
        expect(described_class.format(:relative_percent, 0.1188911792177762)).to eq('+12%')
        expect(described_class.format(:relative_percent, -0.1188911792177762, :text)).to eq('-12%')
        expect(described_class.format(:relative_percent, 0.1188911792177762, :text)).to eq('+12%')
        expect(described_class.format(:relative_percent, -0.1188911792177762, :html)).to eq('-12&percnt;')
        expect(described_class.format(:relative_percent, 0.1188911792177762, :html)).to eq('+12&percnt;')
      end
    end

    context 'with :relative_percent_0dp' do
      it 'formats correctly' do
        expect(described_class.format(:relative_percent_0dp, -0.1188911792177762)).to eq('-12%')
        expect(described_class.format(:relative_percent_0dp, 0.1188911792177762)).to eq('+12%')
        expect(described_class.format(:relative_percent_0dp, -0.1188911792177762, :text)).to eq('-12%')
        expect(described_class.format(:relative_percent_0dp, 0.1188911792177762, :text)).to eq('+12%')
        expect(described_class.format(:relative_percent_0dp, -0.1188911792177762, :html)).to eq('-12&percnt;')
        expect(described_class.format(:relative_percent_0dp, 0.1188911792177762, :html)).to eq('+12&percnt;')
      end
    end

    context 'with :relative_percent no scale' do
      it 'formats correctly' do
        expect(described_class.format({ units: :relative_percent, options: { scale: false } }, -11.8891179217)).to eq('-12%')
      end
    end

    context 'with :comparison_percent' do
      it 'formats correctly' do
        expect(described_class.format(:comparison_percent, 0.005)).to eq('+0.5%')
        expect(described_class.format(:comparison_percent, 0.1)).to eq('+10%')
        expect(described_class.format(:comparison_percent, -0.5)).to eq('-50%')
        expect(described_class.format(:comparison_percent, 10)).to eq('+1,000%')
        expect(described_class.format(:comparison_percent, 4.125)).to eq('+410%')
        expect(described_class.format(:comparison_percent, 0.005, :text)).to eq('+0.5%')
        expect(described_class.format(:comparison_percent, 0.005, :html)).to eq('+0.5&percnt;')
        expect(described_class.format(:comparison_percent, 0.0004, :html)).to eq('0.0&percnt;')
      end
    end
  end

  context 'when date and time formatting' do
    context 'with :date' do
      it 'formats Dates' do
        date = Date.new(2000, 1, 1)
        expect(described_class.format(:date, date, :text)).to eq 'Saturday  1 Jan 2000'
      end

      it 'formats String as a date' do
        expect(described_class.format(:date, '2000-01-01', :text)).to eq 'Saturday  1 Jan 2000'
      end
    end

    context 'with :datetime' do
      it 'formats Date as a date time' do
        date = Date.new(2000, 1, 1)
        expect(described_class.format(:datetime, date, :text)).to eq 'Saturday  1 Jan 2000 00:00'
        date = DateTime.new(2000, 1, 1, 14, 40)
        expect(described_class.format(:datetime, date, :text)).to eq 'Saturday  1 Jan 2000 14:40'
      end

      it 'formats String as a date time' do
        expect(described_class.format(:datetime, '2000-01-01', :text)).to eq 'Saturday  1 Jan 2000 00:00'
      end
    end

    context 'with :date_mmm_yyyy' do
      it 'formats Dates' do
        date = Date.new(2000, 1, 1)
        expect(described_class.format(:date_mmm_yyyy, date, :text)).to eq 'Jan 2000'
      end

      it 'formats String as a date' do
        expect(described_class.format(:date_mmm_yyyy, '2000-01-01', :text)).to eq 'Jan 2000'
      end
    end

    context 'with :days' do
      it 'formats correctly' do
        expect(described_class.format(:days, 1)).to eq '1 day'
        expect(described_class.format(:days, 7)).to eq '7 days'
        expect(described_class.format(:days, '1')).to eq '1 day'
        expect(described_class.format(:days, '7')).to eq '7 days'
      end
    end

    context 'with :years' do
      it 'formats correctly' do
        expect(described_class.format(:years, 2)).to eq '2 years 0 months'
        expect(described_class.format(:years, 2.5)).to eq '2 years 6 months'
        expect(described_class.format(:years, 1)).to eq '12 months'
      end
    end

    context 'with :years_decimal' do
      it 'formats correctly' do
        expect(described_class.format(:years_decimal, 2)).to eq '2 years'
      end
    end

    context 'with :years_range' do
      it 'formats correctly' do
        expect(described_class.format(:years_range, 1..1)).to eq '12 months'
        expect(described_class.format(:years_range, 1..3)).to eq '12 months to 3 years 0 months'
        expect(described_class.format(:years_range, 1..3.2)).to eq '12 months to 3 years 2 months'
      end
    end

    context 'with :timeofday' do
      it 'formats correctly' do
        expect(described_class.format(:timeofday, '01:00')).to eq '01:00'
      end
    end
  end

  describe '#format_time' do
    it 'handles periods less than a day' do
      expect(described_class.format_time(0.000002)).to eq '1 minutes'
      expect(described_class.format_time(0.00002)).to eq '11 minutes'
      expect(described_class.format_time(0.0002)).to eq '2 hours'
      expect(described_class.format_time(0.002)).to eq '18 hours'
    end

    it 'handles periods less than 3 months' do
      expect(described_class.format_time(0.01)).to eq '4 days'
      expect(described_class.format_time(0.1)).to eq '5 weeks'
      expect(described_class.format_time(0.25)).to eq '3 months'
    end

    it 'handles periods of less than 18 months' do
      expect(described_class.format_time(1.5)).to eq '18 months'
    end

    it 'handles periods of less than 5 years' do
      expect(described_class.format_time(2.0)).to eq '2 years 0 months'
    end

    it 'handles longer periods' do
      expect(described_class.format_time(10)).to eq '10 years'
    end
  end

  context 'when money' do
    context 'with pence' do
      it 'formats correctly' do
        expect(described_class.format(:£, 0.5)).to eq '50p'
        expect(described_class.format(:£, 0.5, :html)).to eq '50p'
      end
    end

    context 'with :£' do
      it 'formats correctly' do
        expect(described_class.format(:£, 10)).to eq '£10'
        expect(described_class.format(:£, 10, :html)).to eq '&pound;10'
        expect(described_class.format(:£, Float::NAN)).to eq 'Uncalculable'
        expect(described_class.format(:£, Float::INFINITY)).to eq 'Infinity'
      end
    end

    context 'with :£_0dp' do
      it 'formats correctly' do
        expect(described_class.format(:£_0dp, 10)).to eq '£10'
        expect(described_class.format(:£_0dp, 10, :html)).to eq '&pound;10'
      end
    end

    context 'with :£_per_kva' do
      it 'formats correctly' do
        expect(described_class.format(:£_per_kva, 10)).to eq '£10/kVA'
        expect(described_class.format(:£_per_kva, 10, :html)).to eq '&pound;10/kVA'
      end
    end

    context 'with :£_per_kwh' do
      it 'formats correctly' do
        expect(described_class.format(:£_per_kwh, 10)).to eq '£10/kWh'
        expect(described_class.format(:£_per_kwh, 10, :html)).to eq '&pound;10/kWh'
      end
    end

    context 'with :£_range' do
      it 'formats correctly' do
        expect(described_class.format(:£_range, 730.0..740.0)).to eq '£730'
        expect(described_class.format(:£_range, 730.0..2190.0)).to eq '£730 to £2,200'
        expect(described_class.format(:£_range, -2190.0..2190.0)).to eq '-£2,200 to £2,200'
        expect(described_class.format(:£_range, 0..2190.0)).to eq '0p to £2,200'
      end
    end
  end

  context 'when validating units' do
    it 'identifies known units' do
      expect(described_class.known_unit?(:£)).to be true
      expect(described_class.known_unit?(:kwh_per_day)).to be true
      expect(described_class.known_unit?(:unknown)).to be false
    end

    it 'throws exception when units are unknown' do
      expect do
        described_class.format(:unknown, 10, :text, false)
      end.to raise_exception EnergySparksUnexpectedStateException
    end

    it 'does not throw exception when not strict' do
      expect(described_class.format(:unknown, 10, :text, true)).to eq('10')
    end
  end

  describe '#percent_to_1_dp' do
    it 'returns expected results' do
      expect(described_class.percent_to_1_dp(0.25, :text)).to eq('25.0%')
      expect(described_class.percent_to_1_dp(0.25, :html)).to eq('25.0&percnt;')
    end
  end

  context 'with temperature' do
    it 'formats correctly' do
      expect(described_class.format(:temperature, 10)).to eq('10C')
      expect(described_class.format(:temperature, 10.51)).to eq('10.5C')
    end
  end

  context 'with r2' do
    it 'formats correctly' do
      expect(described_class.format(:r2, 2)).to eq('2.00')
    end
  end

  context 'with school names' do
    it 'formats correctly' do
      expect(described_class.format(:school_name, 'Junior School')).to eq('Junior School')
    end
  end

  context 'with nil values' do
    it 'formats correctly' do
      expect(described_class.format(:date, nil)).to eq('')
    end
  end

  context 'with floats' do
    it 'formats correctly' do
      expect(described_class.format(Float, 0.01)).to eq('0.01')
    end

    it 'handles infinity' do
      expect(described_class.format(Float, Float::NAN)).to eq('Uncalculable')
      expect(described_class.format(Float, Float::INFINITY)).to eq('Infinity')
      expect(described_class.format(Float, -Float::INFINITY)).to eq('-Infinity')
    end
  end

  context 'when doing default formatting of other units' do
    it 'formats correctly' do # rubocop:todo RSpec/ExampleLength
      expect(described_class.format(:accounting_cost, 2)).to eq('£2')
      expect(described_class.format(:bev_car, 2)).to eq('2 km')
      expect(described_class.format(:boiler_start_time, 2)).to eq('2 boiler start time')
      expect(described_class.format(:carnivore_dinner, 2)).to eq('2 dinners')
      expect(described_class.format(:co2, 2)).to eq('2 kg CO2')
      expect(described_class.format(:co2t, 2)).to eq('2 tonnes CO2')
      expect(described_class.format(:co2t, 2)).to eq('2 tonnes CO2')
      expect(described_class.format(:computer_console, 2)).to eq('2 computer consoles')
      expect(described_class.format(:fuel_type, 2)).to eq('2')
      expect(described_class.format(:home, 2)).to eq('2 homes')
      expect(described_class.format(:homes_electricity, 2)).to eq('2 homes (electricity usage)')
      expect(described_class.format(:homes_gas, 2)).to eq('2 homes (gas usage)')
      expect(described_class.format(:hour, 2)).to eq('2 hours')
      expect(described_class.format(:ice_car, 2)).to eq('2 km')
      expect(described_class.format(:kettle, 2)).to eq('2 kettles')
      expect(described_class.format(:kg, 2)).to eq('2 kg')
      expect(described_class.format(:kg_co2_per_kwh, 2)).to eq('2 kg CO2/kWh')
      expect(described_class.format(:km, 2)).to eq('2 km')
      expect(described_class.format(:kva, 2)).to eq('2 kVA')
      expect(described_class.format(:kw, 2)).to eq('2 kW')
      expect(described_class.format(:kwh, 2)).to eq('2 kWh')
      expect(described_class.format(:kwh_per_day, 2)).to eq('2 kWh/day')
      expect(described_class.format(:kwh_per_day_per_c, 2)).to eq('2 kWh/day/C')
      expect(described_class.format(:kwp, 2)).to eq('2 kWp')
      expect(described_class.format(:library_books, 2)).to eq('2 library books')
      expect(described_class.format(:litre, 2)).to eq('2 litres')
      expect(described_class.format(:m2, 2)).to eq('2 m2')
      expect(described_class.format(:m2, 2, :html)).to eq('2 m<sup>2</sup>')
      expect(described_class.format(:meters, 2)).to eq('2 meters')
      expect(described_class.format(:morning_start_time, 2)).to eq('2 time of day')
      expect(described_class.format(:offshore_wind_turbine_hours, 2)).to eq('2 offshore wind turbine hours')
      expect(described_class.format(:offshore_wind_turbines, 2)).to eq('2 offshore wind turbines')
      expect(described_class.format(:onshore_wind_turbine_hours, 2)).to eq('2 onshore wind turbine hours')
      expect(described_class.format(:onshore_wind_turbines, 2)).to eq('2 onshore wind turbines')
      expect(described_class.format(:opt_start_standard_deviation, 2)).to eq('2 standard deviation (hours)')
      expect(described_class.format(:optimum_start_sensitivity, 2)).to eq('2 hours/C')
      expect(described_class.format(:panels, 2)).to eq('2 solar PV panels')
      expect(described_class.format(:pupils, 2)).to eq('2 pupils')
      expect(described_class.format(:shower, 2)).to eq('2 showers')
      expect(described_class.format(:smartphone, 2)).to eq('2 smartphone charges')
      expect(described_class.format(:solar_panels, 2)).to eq('2 solar panels')
      expect(described_class.format(:solar_panels_in_a_year, 2)).to eq('2 solar panels in a year')
      expect(described_class.format(:teaching_assistant, 2)).to eq('2 teaching assistant')
      expect(described_class.format(:teaching_assistant_hours, 2)).to eq('2 teaching assistant (hours)')
      expect(described_class.format(:tree, 2)).to eq('2 trees')
      expect(described_class.format(:tv, 2)).to eq('2 tvs')
      expect(described_class.format(:vegetarian_dinner, 2)).to eq('2 dinners')
      expect(described_class.format(:w, 2)).to eq('2 W')
    end
  end
end
