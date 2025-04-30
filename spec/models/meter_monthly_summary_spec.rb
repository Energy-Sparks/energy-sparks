# frozen_string_literal: true

require 'rails_helper'

describe MeterMonthlySummary do
  describe '#self.from_meter' do
    it 'processes' do
      end_date = Date.new(2019, 6, 2)
      meter = create(:gas_meter_with_validated_reading_dates, start_date: Date.new(2019, 5, 1), end_date:)
      travel_to(end_date + 1.day)
      expect(described_class.from_meter(meter)).to contain_exactly(
        have_attributes(year: 2018, consumption: [0] * 4 + [4309, 278], quality: [nil] * 4 + %w[actual incomplete],
                        total: 4587.0))
      create(:amr_validated_reading, meter:, reading_date: Time.zone.today)
      expect(described_class.from_meter(meter)).to contain_exactly(
        have_attributes(year: 2018, consumption: [0] * 4 + [4309, 417], quality: [nil] * 4 + %w[actual incomplete],
                        total: 4726))
      expect(meter.meter_monthly_summaries.count).to eq(1)
    end
  end
end
