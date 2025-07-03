# frozen_string_literal: true

require 'rails_helper'

describe Aggregation::ValidateAmrData, type: :service do
  subject(:validator) { data[0] }

  def setup(**kwargs)
    kwargs = { kwh_data_x48: Array.new(48, 0.44), day_count: 9 }.merge(kwargs)
    meter = kwargs.include?(:meter) ? kwargs.delete(:meter) : build(:meter, type: :electricity, **kwargs)
    meter_collection = build(:meter_collection)
    meter.instance_variable_set(:@meter_collection, meter_collection)
    validator = described_class.new(meter, max_days_missing_data, meter_collection.holidays,
                                    meter_collection.temperatures)
    [validator, meter]
  end

  before { travel_to Date.new(2025, 5, 3) }

  let(:data) { setup }
  let(:meter_collection) { meter.meter_collection }
  let(:meter) { data[1] }
  let(:max_days_missing_data) { 50 }

  context 'with real data' do
    let(:meter_collection) { load_unvalidated_meter_collection(school: 'acme-academy', validate_and_aggregate: false) }
    let(:meter) { meter_collection.meter?(1_591_058_886_735) }
    let(:validator) do
      described_class.new(meter, max_days_missing_data, meter_collection.holidays, meter_collection.temperatures)
    end

    it 'validates' do
      validator.validate(debug_analysis: true)
      expect(validator.data_problems).to be_empty
    end
  end

  it 'replaces missing night time solar readings with 0' do
    missing_date = meter.amr_data.keys.sort[1]
    meter.amr_data.delete(missing_date)
    meter.instance_variable_set(:@meter_type, :solar_pv)
    validator.validate(debug_analysis: true)
    expect(validator.data_problems).to be_empty
    expect(meter.amr_data[missing_date].kwh_data_x48).to include(0.0)
  end

  context 'with override_night_to_zero' do
    before { meter.meter_correction_rules << { override_night_to_zero: nil } }

    def arbitrary_night_readings(meter)
      meter.amr_data.to_a.sort.map { |data| data[1].kwh_data_x48[5] }
    end

    it 'replace night time readings with a rule' do
      validator.validate(debug_analysis: true)
      expect(arbitrary_night_readings(meter)).to eq(Array.new(8, 0.0))
      expect(meter.amr_data.first[1].type).to eq('SOLN')
    end

    it 'replace night time readings with a rule with dates' do
      meter.meter_correction_rules[-1] = { override_night_to_zero: { start_date: meter.amr_data.start_date + 1.day,
                                                                     end_date: meter.amr_data.start_date + 2.days } }
      validator.validate(debug_analysis: true)
      expect(arbitrary_night_readings(meter)).to eq([0.44, 0.0, 0.0, 0.44, 0.44, 0.44, 0.44, 0.44])
    end

    it 'has with missing data' do
      missing_date = meter.amr_data.keys.sort[1]
      meter.amr_data.delete(missing_date)
      validator.validate(debug_analysis: true)
      expect(arbitrary_night_readings(meter)).to eq([0.0, 0.0123456, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
    end

    it 'is already zero' do
      date = meter.amr_data.keys.sort[1]
      meter.amr_data[date].kwh_data_x48.fill(0.0)
      validator.validate
      expect(meter.amr_data[date].type).to eq('ORIG')
      expect(arbitrary_night_readings(meter)).to eq(Array.new(8, 0.0))
    end
  end

  def validate_and_return_arbitrary_reading(**kwargs)
    validator, meter = setup(**kwargs)
    date = meter.amr_data.keys[2]
    yield(meter.amr_data[date]) if block_given?
    validator.validate
    meter.amr_data[date]
  end

  it 'corrects dcc known bad values' do
    reading = validate_and_return_arbitrary_reading(dcc_meter: true) do |reading|
      reading.kwh_data_x48[0] = 4_294_967.295
    end
    expect(reading.type).to eq('DCCP')
    expect(reading.kwh_data_x48[0]).to eq(0.44)
  end

  context 'with negative readings' do
    it 'corrects negative readings' do
      reading = validate_and_return_arbitrary_reading(kwh_data_x48: [-1] + Array.new(47, 0.5))
      expect(reading.kwh_data_x48[0]).to eq(0.5)
      expect(reading.type).to eq('RNEG')
    end

    it 'corrects many negative readings' do
      reading = validate_and_return_arbitrary_reading { |reading| reading.kwh_data_x48[0..6] = Array.new(7, -0.1) }
      expect(reading.kwh_data_x48[0]).to eq(0.44)
      expect(reading.type).to eq('RNEG')
      expect(reading.substitute_date).not_to be_nil
    end

    %i[solar_pv exported_solar_pv].each do |type|
      it "doesn't correct #{type} meters" do
        meter = build(:meter, type:, kwh_data_x48: [-1] + Array.new(47, 0.0)) # rubocop:disable Performance/CollectionLiteralInLoop
        reading = validate_and_return_arbitrary_reading(meter:)
        expect(reading.type).to eq('ORIG')
        expect(reading.kwh_data_x48[0]).to eq(-1)
      end
    end
  end
end
