# frozen_string_literal: true

require 'rails_helper'

describe Schools::Advice::ConsumptionByMonthService, type: :service do
  let(:school) { create(:school) }
  let(:start_date) { Date.yesterday - 7 }
  let(:aggregate_meter) do
    build(:meter_collection, :with_aggregated_aggregate_meter, start_date:,
                                                               random_generator: Random.new(24),
                                                               rates: create_flat_rate(rate: 1, standing_charge: 1))
      .aggregate_meter(:electricity)
  end

  before { travel_to(Date.new(2024, 12, 1)) }

  def empty_expected
    (0..11).to_h do |i|
      [Date.new(2023, 12) + i.months,
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
        expect(described_class.consumption_by_month(aggregate_meter, school)).to eq(expected)
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
        expect(described_class.consumption_by_month(aggregate_meter, school)).to eq(expected)
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
        expect(described_class.consumption_by_month(aggregate_meter, school).sort.to_h).to eq(expected)
      end
    end
  end
end
