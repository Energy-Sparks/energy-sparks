# frozen_string_literal: true

require 'rails_helper'

describe Schools::Advice::ConsumptionByMonthService, type: :service do
  let(:school) { create(:school) }
  let(:start_date) { Date.yesterday - 7 }
  let(:meter_collection) do
    build(:meter_collection, :with_aggregated_aggregate_meter, start_date:,
                                                               random_generator: Random.new(24),
                                                               rates: create_flat_rate(rate: 1, standing_charge: 1))
  end

  before { travel_to(Date.new(2024, 12, 1)) }

  def empty_expected(start_date: Date.new(2023, 12))
    (0..11).to_h do |i|
      [start_date + i.months,
       { change: { co2: nil, gbp: nil, kwh: nil },
         current: { co2: nil, gbp: nil, kwh: nil, missing: true },
         previous: { co2: nil, gbp: nil, kwh: nil, missing: true } }]
    end
  end

  describe '#consumption_by_month' do
    context 'with a week of readings' do
      it 'has the correct consumption' do
        expected = empty_expected
        expected[Date.new(2024, 11)][:current].merge!(co2: 96.384, gbp: 384, kwh: 384)
        expect(described_class.consumption_by_month(meter_collection, school, :electricity)).to eq(expected)
      end
    end

    context 'with a week of readings and a manual reading' do
      before do
        school.manual_readings.create!(month: Date.new(2024, 11), electricity: 1)
        create(:secr_co2_equivalence, year: 2024)
      end

      it 'has the correct consumption' do
        expected = empty_expected
        expected[Date.new(2024, 11)][:current].merge!(co2: 0.2, kwh: 1, manual: true, missing: false)
        expect(described_class.consumption_by_month(meter_collection, school, :electricity)).to eq(expected)
      end
    end

    context 'with 18 months of readings' do
      let(:start_date) { 18.months.ago.to_date }

      it 'has the correct consumption' do
        expected = empty_expected
        expected.values.zip(
          [373.488, 373.488, 349.392, 373.488, 361.44, 373.488, 361.44, 373.488, 373.488, 361.44, 373.488, 361.44],
          [1488, 1488, 1392, 1488, 1440, 1488, 1440, 1488, 1488, 1440, 1488, 1440],
          [nil, nil, nil, nil, nil, nil, 361.44, 373.488, 373.488, 361.44, 373.488, 361.44],
          [nil, nil, nil, nil, nil, nil, 1440, 1488, 1488, 1440, 1488, 1440]
        ).each do |consumption, co2, kwh, previous_co2, previous_kwh|
          consumption[:current].merge!(co2:, kwh:, gbp: kwh.to_f, missing: false)
          unless previous_co2.nil?
            consumption[:previous].merge!(co2: previous_co2, kwh: previous_kwh, gbp: previous_kwh.to_f, missing: false)
            consumption[:change].merge!(co2: 0.0, gbp: 0.0, kwh: 0)
          end
        end
        expect(described_class.consumption_by_month(meter_collection, school, :electricity).sort.to_h).to eq(expected)
      end
    end

    context 'with no readings' do
      let(:meter_collection) { build(:meter_collection) }

      it 'has the correct consumption' do
        expect(described_class.consumption_by_month(meter_collection, school, :electricity)).to \
          eq(empty_expected(start_date: Date.new(2024, 1)))
      end
    end

    context 'with only manual readings' do
      let(:meter_collection) { build(:meter_collection) }

      before do
        school.manual_readings.create!(month: Date.new(2024, 12), electricity: 1)
        create(:secr_co2_equivalence, year: 2024)
      end

      it 'has the correct consumption' do
        expected = empty_expected(start_date: Date.new(2024, 1))
        expected[Date.new(2024, 12)][:current].merge!(co2: 0.2, kwh: 1, manual: true, missing: false)
        expect(described_class.consumption_by_month(meter_collection, school, :electricity)).to eq(expected)
      end
    end
  end
end
