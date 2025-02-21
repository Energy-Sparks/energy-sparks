# frozen_string_literal: true

require 'spec_helper'

describe Baseload::BaseloadCalculator, type: :service do
  let(:meter_collection) { build(:meter_collection, :with_electricity_meter) }

  describe '.for_meter' do
    subject(:calculator) { described_class.for_meter(meter) }

    let(:meter) { meter_collection.electricity_meters.first }

    context 'when school has sheffield solar' do
      before do
        allow(meter).to receive(:sheffield_simulated_solar_pv_panels?).and_return(true)
      end

      it 'returns calculator' do
        expect(calculator).to be_a(Baseload::OvernightBaseloadCalculator)
      end

      context 'with FEATURE_FLAG_MIDNIGHT_BASELOAD enabled' do
        it 'returns the new implementation' do
          ClimateControl.modify FEATURE_FLAG_MIDNIGHT_BASELOAD: 'true' do
            expect(calculator).to be_a Baseload::AroundMidnightBaseloadCalculator
          end
        end
      end
    end

    context 'when school does not have sheffield solar' do
      it 'returns calculator' do
        expect(calculator).to be_a(Baseload::StatisticalBaseloadCalculator)
      end
    end
  end

  describe '.calculator_for' do
    subject(:calculator)      { described_class.calculator_for(amr_data, sheffield_solar_pv) }

    let(:amr_data)            { meter_collection.electricity_meters.first.amr_data }

    context 'with sheffield solar' do
      let(:sheffield_solar_pv) { true }

      it 'returns calculator' do
        expect(calculator).to be_a(Baseload::OvernightBaseloadCalculator)
      end

      context 'with FEATURE_FLAG_MIDNIGHT_BASELOAD enabled' do
        it 'returns the new implementation' do
          ClimateControl.modify FEATURE_FLAG_MIDNIGHT_BASELOAD: 'true' do
            expect(calculator).to be_a Baseload::AroundMidnightBaseloadCalculator
          end
        end
      end
    end

    context 'without sheffield solar' do
      let(:sheffield_solar_pv) { false }

      it 'returns calculator' do
        expect(calculator).to be_a(Baseload::StatisticalBaseloadCalculator)
      end
    end
  end

  describe '#average_baseload_kw_date_range' do
    # create one of the sub-classes for testing
    subject(:calculator)  { Baseload::StatisticalBaseloadCalculator.new(amr_data) }

    let(:start_date)      { Date.new(2023, 1, 1) }
    let(:average_baseload_kw_date_range) { calculator.average_baseload_kw_date_range(start_date, end_date) }
    let(:end_date)        { Date.new(2023, 1, 2) }
    let(:kwh_data_x48)    { Array.new(48, 0.1) }
    let(:amr_data)        do
      build(:amr_data, :with_date_range, start_date: start_date, end_date: end_date, kwh_data_x48: kwh_data_x48)
    end

    it 'calculates the average in kW' do
      expect(average_baseload_kw_date_range).to be_within(0.0000001).of(0.2)
    end
  end

  describe '#baseload_kwh_date_range' do
    # create one of the sub-classes for testing
    subject(:calculator)  { Baseload::StatisticalBaseloadCalculator.new(amr_data) }

    let(:start_date)      { Date.new(2023, 1, 1) }
    let(:baseload_kwh_date_range) { calculator.baseload_kwh_date_range(start_date, end_date) }
    let(:end_date)        { Date.new(2023, 1, 2) }
    let(:kwh_data_x48)    { Array.new(48, 0.1) }
    let(:amr_data)        do
      build(:amr_data, :with_date_range, start_date: start_date, end_date: end_date, kwh_data_x48: kwh_data_x48)
    end

    it 'calculates the total baseload in kWh' do
      # 2 days, 0.1 kw baseload is 9.6 kWh (24 * 0.2 * 2)
      expect(baseload_kwh_date_range).to be_within(0.0000001).of(9.6)
    end
  end
end
