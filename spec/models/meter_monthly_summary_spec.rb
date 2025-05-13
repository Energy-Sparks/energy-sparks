# frozen_string_literal: true

require 'rails_helper'

describe MeterMonthlySummary do
  describe '#self.from_meter' do
    it 'create and updates' do
      end_date = Date.new(2019, 6, 2)
      start_date = Date.new(2019, 5, 1)
      meter_collection, meter = setup_meters(start_date, end_date)
      travel_to(end_date + 1.day)
      described_class.create_or_update_from_school(meter.school, meter_collection)
      expect_summaries(meter, ([0] * 4) + [4309, 278], 4587)

      create(:amr_validated_reading, meter:, reading_date: Time.zone.today)
      described_class.create_or_update_from_school(meter.school, meter_collection)
      expect_summaries(meter, ([0] * 4) + [4309, 417], 4726)
    end

    def expect_summaries(meter, consumption, total)
      expect(meter.meter_monthly_summaries.reload).to contain_exactly(
        have_attributes(year: 2018, type: 'consumption', consumption:,
                        quality: ([nil] * 4) + %w[actual incomplete], total:),
        have_attributes(year: 2018, type: 'generation', consumption: ([0] * 4) + [1488, 96],
                        quality: ([nil] * 4) + %w[actual incomplete], total: 1584),
        have_attributes(year: 2018, type: 'self_consume', consumption: ([0] * 4) + [1488, 96],
                        quality: ([nil] * 4) + %w[actual incomplete], total: 1584),
        have_attributes(year: 2018, type: 'export', consumption: ([0] * 4) + [1488, 96],
                        quality: ([nil] * 4) + %w[actual incomplete], total: 1584)
      )
    end

    def setup_meters(start_date, end_date)
      sub_meters = {
        mains_consume: build(:meter, amr_data: build(:amr_data, :with_date_range, start_date:, end_date:)),
        generation: build(:meter, amr_data: build(:amr_data, :with_date_range, start_date:, end_date:,
                                                                               kwh_data_x48: [1] * 48)),
        self_consume: build(:meter, amr_data: build(:amr_data, :with_date_range, start_date:, end_date:,
                                                                                 kwh_data_x48: [1] * 48)),
        export: build(:meter, amr_data: build(:amr_data, :with_date_range, start_date:, end_date:,
                                                                           kwh_data_x48: [1] * 48))
      }
      meter_collection = build(:meter_collection, :with_sub_meters, sub_meters:, start_date:, end_date:)
      meter = create(:electricity_meter_with_validated_reading_dates, start_date:, end_date:)
      create(:solar_pv_attribute, meter:)
      meter_collection.aggregated_electricity_meters.set_mpan_mprn_id(meter.mpan_mprn)
      [meter_collection, meter]
    end
  end
end
