# frozen_string_literal: true

require 'rails_helper'

describe Aggregation::ValidateAmrData, type: :service do
  def create_validator(meter, max_days_missing_data: 50)
    described_class.new(meter, max_days_missing_data, meter.meter_collection.holidays,
                        meter.meter_collection.temperatures)
  end

  def create_meter(**kwargs)
    kwargs = { kwh_data_x48: Array.new(48, 0.44), day_count: 9, type: :electricity }.merge(kwargs)
    meter_collection = build(:meter_collection)
    build(:meter, meter_collection:, **kwargs)
  end

  before { travel_to Date.new(2025, 5, 3) }

  context 'with real data' do
    it 'validates' do
      meter = load_unvalidated_meter_collection(school: 'acme-academy', validate_and_aggregate: false)
              .meter?(1_591_058_886_735)
      validator = create_validator(meter)
      validator.validate
      expect(validator.data_problems).to be_empty
    end
  end

  def modify_arbitrary_reading_and_validate(meter)
    date = meter.amr_data.keys.sort[1]
    yield(meter.amr_data[date], date) if block_given?
    validator = create_validator(meter)
    validator.validate
    [meter.amr_data[date], validator]
  end

  it 'replaces missing night time solar readings with 0' do
    meter = create_meter(type: :solar_pv)
    reading, validator = modify_arbitrary_reading_and_validate(meter) { |_reading, date| meter.amr_data.delete(date) }
    expect(validator.data_problems).to be_empty
    expect(reading.kwh_data_x48[0..3]).to eq([0.0] * 4)
    expect(reading.type).to eq('PROB')
  end

  context 'with override_night_to_zero' do
    let(:meter) do
      meter = create_meter
      meter.meter_correction_rules << { override_night_to_zero: nil }
      meter
    end

    def arbitrary_night_readings(meter)
      meter.amr_data.to_a.sort.map { |data| data[1].kwh_data_x48[5] }
    end

    it 'replace night time readings with a rule' do
      create_validator(meter).validate
      expect(arbitrary_night_readings(meter)).to eq(Array.new(8, 0.0))
      expect(meter.amr_data.first[1].type).to eq('SOLN')
    end

    it 'replace night time readings with a rule with dates' do
      meter.meter_correction_rules[-1] = { override_night_to_zero: { start_date: meter.amr_data.start_date + 1.day,
                                                                     end_date: meter.amr_data.start_date + 2.days } }
      create_validator(meter).validate(debug_analysis: true)
      expect(arbitrary_night_readings(meter)).to eq([0.44, 0.0, 0.0, 0.44, 0.44, 0.44, 0.44, 0.44])
    end

    it 'has with missing data' do
      modify_arbitrary_reading_and_validate(meter) { |_reading, date| meter.amr_data.delete(date) }
      expect(arbitrary_night_readings(meter)).to eq([0.0, 0.0123456, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
    end

    it 'is already zero' do
      reading, = modify_arbitrary_reading_and_validate(meter) { |reading,| reading.kwh_data_x48.fill(0.0) }
      expect(reading.type).to eq('ORIG')
      expect(arbitrary_night_readings(meter)).to eq(Array.new(8, 0.0))
    end
  end

  it 'corrects dcc known bad values' do
    reading, = modify_arbitrary_reading_and_validate(create_meter(dcc_meter: true)) do |reading,|
      reading.kwh_data_x48[0] = 4_294_967.295
    end
    expect(reading.type).to eq('DCCP')
    expect(reading.kwh_data_x48[0]).to eq(0.44)
  end

  context 'with negative readings' do
    it 'corrects negative readings' do
      reading, = modify_arbitrary_reading_and_validate(create_meter(kwh_data_x48: [-1] + ([0.5] * 47)))
      expect(reading.kwh_data_x48[0]).to eq(0.5)
      expect(reading.type).to eq('RNEG')
    end

    it 'corrects many negative readings' do
      reading, = modify_arbitrary_reading_and_validate(create_meter) do |reading|
        reading.kwh_data_x48[0..6] = Array.new(7, -0.1)
      end
      expect(reading.kwh_data_x48[0]).to eq(0.44)
      expect(reading.type).to eq('RNEG')
      expect(reading.substitute_date).to eq(Date.new(2025, 4, 27))
    end

    context 'with entire day negative' do
      context 'when there are possible substitutes' do
        it 'substitutes the entire day' do
          reading, = modify_arbitrary_reading_and_validate(create_meter) do |reading|
            reading.kwh_data_x48[0..47] = Array.new(48, -0.1)
          end
          expect(reading.kwh_data_x48[0]).to eq(0.44)
          expect(reading.type).to eq('RNEG')
          expect(reading.substitute_date).to eq(Date.new(2025, 4, 27))
        end
      end

      context 'when there are no possible substitutes' do
        it 'falls back to other validations' do
          reading, = modify_arbitrary_reading_and_validate(create_meter(kwh_data_x48: Array.new(48, -0.1)))
          expect(reading.type).to eq('PROB') # small amount missing, so will be filled with PROB data
        end
      end
    end

    %i[solar_pv exported_solar_pv].each do |type|
      it "doesn't correct #{type} meters" do
        kwh_data_x48 = Array.new(48, 0).tap { |a| a[24] = -1 }
        reading, = modify_arbitrary_reading_and_validate(create_meter(type:, kwh_data_x48:))
        expect(reading.type).to eq('ORIG')
        expect(reading.kwh_data_x48[24]).to eq(-1)
      end
    end
  end

  context 'with overnight solar' do
    it 'zeroes' do
      reading, = modify_arbitrary_reading_and_validate(create_meter(type: :solar_pv))
      expect(reading.type).to eq('SOLN')
      expect(reading.kwh_data_x48[0..3]).to eq([0.0] * 4)
    end

    %i[electricity exported_solar_pv gas].each do |type|
      it "doesn't zero #{type}" do
        reading, = modify_arbitrary_reading_and_validate(create_meter(type:))
        expect(reading.type).to eq('ORIG')
        expect(reading.kwh_data_x48[0..3]).to eq(Array.new(4, 0.44))
      end
    end
  end

  context 'when filling in missing readings' do
    context 'with an electricity meter' do
      subject(:substituted) { meter.amr_data[missing_date] }

      let(:meter) { create_meter(type: :electricity) }
      let(:missing_date) { meter.amr_data.end_date - 2 }

      before do
        meter.amr_data.delete(missing_date)
        validator = create_validator(meter)
        validator.validate
      end

      it 'applies a simple substitution' do
        expect(substituted.type).to eq('ESS1')
        expect(substituted.kwh_data_x48).to eq(meter.amr_data[substituted.substitute_date].kwh_data_x48)
      end
    end

    context 'with a gas meter' do
      subject(:substituted) { meter.amr_data[missing_date] }

      let(:meter) { create_meter(type: :gas) }
      let(:missing_date) { meter.amr_data.end_date - 2 }

      context 'when there is no heating model' do
        before do
          meter.amr_data.delete(missing_date)
          validator = create_validator(meter)
          validator.validate
        end

        it 'applies a simple substitution' do
          expect(substituted.type).to eq('GSS1')
          expect(substituted.kwh_data_x48).to eq(meter.amr_data[substituted.substitute_date].kwh_data_x48)
        end
      end

      context 'when there is a heating model' do
        let(:regression_model_parameters) { { base_temperature: 1.0 } }
        let(:missing_day_prediction) { 1.0 }
        let(:substitute_day_prediction) { 2.0 }

        before do
          meter.amr_data.delete(missing_date)
          model_cache = instance_double(AnalyseHeatingAndHotWater::ModelCache)
          allow(AnalyseHeatingAndHotWater::ModelCache).to receive(:new).and_return(model_cache)

          heating_model = instance_double(AnalyseHeatingAndHotWater::HeatingModelTemperatureSpace)
          allow(model_cache).to receive(:create_and_fit_model).and_return(heating_model)
          allow(heating_model).to receive_messages(
            heat_on_missing_data?: true,
            regression_model_parameters: regression_model_parameters,
          )
          allow(heating_model).to receive(:predicted_kwh).and_return(missing_day_prediction, substitute_day_prediction)

          validator = create_validator(meter)
          validator.validate
        end

        context 'when there are predicted differences in consumption' do
          it 'applies a temperature compensation' do
            expect(substituted.type).to eq('GSS1')
            expect(substituted.one_day_kwh).to eq(meter.amr_data[substituted.substitute_date].one_day_kwh / 2)
          end
        end

        context 'when there is no predicted usage' do
          let(:missing_day_prediction) { 0.0 }
          let(:substitute_day_prediction) { 0.0 }

          it 'uses original readings' do
            expect(substituted.type).to eq('GSS1')
            expect(substituted.kwh_data_x48).to eq(meter.amr_data[substituted.substitute_date].kwh_data_x48)
          end
        end

        context 'when there is a negative prediction' do
          let(:substitute_day_prediction) { -0.5 }

          it 'uses original readings' do
            expect(substituted.type).to eq('GSS1')
            expect(substituted.kwh_data_x48).to eq(meter.amr_data[substituted.substitute_date].kwh_data_x48)
          end
        end

        context 'when temperatures are above base temperature' do
          let(:regression_model_parameters) { { base_temperature: 0.0 } }

          it 'uses original readings' do
            expect(substituted.type).to eq('GSS1')
            expect(substituted.kwh_data_x48).to eq(meter.amr_data[substituted.substitute_date].kwh_data_x48)
          end
        end
      end
    end
  end
end
