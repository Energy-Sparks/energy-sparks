# frozen_string_literal: true

require 'rails_helper'

describe MeterMonthlySummary do
  describe '#self.create_or_update_from_school' do
    let(:start_date) { Date.new(2019, 5, 1) }
    let(:end_date) { Date.new(2019, 6, 2) }
    let(:reading_type) { 'ORIG' }

    let(:expected_monthly_consumption) { ([0] * 4) + [4464, 288] }

    def build_meter_collection(start_date:, end_date:, reading_type:)
      sub_meters = {
        mains_consume: build(:meter,
                             amr_data: build(:amr_data,
                                             :with_date_range,
                                             start_date:,
                                             end_date:,
                                             reading_type:,
                                             kwh_data_x48: [3] * 48))
      }
      meter_collection = build(:meter_collection, :with_electricity_meter)
      meter_collection.electricity_meters.first.sub_meters.merge!(sub_meters)
      meter_collection
    end

    before do
      travel_to(end_date + 1.day)
      described_class.create_or_update_from_school(meter.school, meter_collection)
    end

    context 'with an electricity meter' do
      let(:meter_collection) do
        build_meter_collection(start_date:, end_date:, reading_type:)
      end

      let(:meter) do
        meter = create(:electricity_meter_with_validated_reading_dates, start_date:, end_date:)
        meter_collection.electricity_meters.first.sub_meters[:mains_consume].set_mpan_mprn_id(meter.mpan_mprn)
        meter
      end

      context 'with complete months' do
        let(:end_date) { Date.new(2019, 6, 30) }
        let(:expected_monthly_consumption) { ([0] * 4) + [4464, 4320] }

        it 'creates expected summary' do
          expect(meter.meter_monthly_summaries.reload).to contain_exactly(
            have_attributes(year: 2018, type: 'consumption', consumption: expected_monthly_consumption,
                            quality: ([nil] * 4) + %w[actual actual], total: expected_monthly_consumption.sum)
          )
        end
      end

      context 'with an incomplete month' do
        it 'creates expected summary' do
          expect(meter.meter_monthly_summaries.reload).to contain_exactly(
            have_attributes(year: 2018, type: 'consumption', consumption: expected_monthly_consumption,
                            quality: ([nil] * 4) + %w[actual incomplete], total: expected_monthly_consumption.sum)
          )
        end
      end

      context 'with corrected data' do
        let(:reading_type) { 'ESS1' }

        it 'creates expected summary' do
          expect(meter.meter_monthly_summaries.reload).to contain_exactly(
            have_attributes(year: 2018, type: 'consumption', consumption: expected_monthly_consumption,
                            quality: ([nil] * 4) + %w[corrected incomplete], total: expected_monthly_consumption.sum)
          )
        end
      end

      context 'with estimated data' do
        let(:reading_type) { 'EST' }

        it 'creates expected summary' do
          expect(meter.meter_monthly_summaries.reload).to contain_exactly(
            have_attributes(year: 2018, type: 'consumption', consumption: expected_monthly_consumption,
                            quality: ([nil] * 4) + %w[estimated incomplete], total: expected_monthly_consumption.sum)
          )
        end
      end
    end

    context 'with a electricity meter with solar' do
      let(:meter_collection) do
        meter_collection = build_meter_collection(start_date:, end_date:, reading_type: 'ORIG')
        sub_meters = {
          generation: build(:meter, amr_data: build(:amr_data, :with_date_range, start_date:, end_date:,
                                                                                 kwh_data_x48: [1] * 48)),
          self_consume: build(:meter, amr_data: build(:amr_data, :with_date_range, start_date:, end_date:,
                                                                                   kwh_data_x48: [1] * 48)),
          export: build(:meter, amr_data: build(:amr_data, :with_date_range, start_date:, end_date:,
                                                                             kwh_data_x48: [1] * 48))
        }
        meter_collection.electricity_meters.first.sub_meters.merge!(sub_meters)
        meter_collection
      end

      let(:meter) do
        meter = create(:electricity_meter_with_validated_reading_dates, start_date:, end_date:)
        meter_collection.electricity_meters.first.set_meter_attributes(solar_pv_mpan_meter_mapping: true)
        meter_collection.electricity_meters.first.sub_meters[:mains_consume].set_mpan_mprn_id(meter.mpan_mprn)
        meter
      end

      it 'creates and updates summary' do
        expect_summaries(meter, ([0] * 4) + [4464, 288])

        meter_collection.electricity_meters.first.sub_meters[:mains_consume].amr_data[Date.new(2019, 6, 3)] =
          build(:one_day_amr_reading, date: Date.new(2019, 6, 3), kwh_data_x48: [3] * 48)
        described_class.create_or_update_from_school(meter.school, meter_collection)
        expect_summaries(meter, ([0] * 4) + [4464, 432])
      end

      def expect_summaries(meter, consumption)
        expect(meter.meter_monthly_summaries.reload).to contain_exactly(
          have_attributes(year: 2018, type: 'consumption', consumption:,
                          quality: ([nil] * 4) + %w[actual incomplete], total: consumption.sum),
          have_attributes(year: 2018, type: 'generation', consumption: ([0] * 4) + [1488, 96],
                          quality: ([nil] * 4) + %w[actual incomplete], total: 1584),
          have_attributes(year: 2018, type: 'self_consume', consumption: ([0] * 4) + [1488, 96],
                          quality: ([nil] * 4) + %w[actual incomplete], total: 1584),
          have_attributes(year: 2018, type: 'export', consumption: ([0] * 4) + [1488, 96],
                          quality: ([nil] * 4) + %w[actual incomplete], total: 1584)
        )
      end
    end
  end
end
