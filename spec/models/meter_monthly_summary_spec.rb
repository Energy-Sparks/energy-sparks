# frozen_string_literal: true

require 'rails_helper'

describe MeterMonthlySummary do
  describe '#self.from_meter' do
    it 'processes' do
      travel_to(Date.parse('03/06/2019'))
      meter = create(:gas_meter_with_validated_reading_dates)
      expect(described_class.from_meter(meter)).to contain_exactly(
        have_attributes(year: 2018, consumption: [0] * 5 + [278], quality: [nil] * 5 + ['incomplete'], total: 278))
    end
  end
end
