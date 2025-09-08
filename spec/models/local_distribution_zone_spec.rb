require 'rails_helper'

describe LocalDistributionZone do
  subject(:zone) { create(:local_distribution_zone) }

  describe '#kwh_per_m3' do
    it 'gets the default when no suitable reading' do
      default = 11.1
      expect(described_class.kwh_per_m3(nil, nil)).to be_within(0.001).of(default)
      expect(described_class.kwh_per_m3(zone, nil)).to be_within(0.001).of(default)
      expect(described_class.kwh_per_m3(nil, Date.new(2025, 2, 20))).to be_within(0.001).of(default)
      expect(described_class.kwh_per_m3(zone, Date.new(2025, 2, 20))).to be_within(0.001).of(default)
    end

    it 'works getting from readings' do
      create(:local_distribution_zone_reading, local_distribution_zone: zone, date: Date.new(2025, 3, 9),
                                               calorific_value: 1.0)
      expect(described_class.kwh_per_m3(zone, Date.new(2025, 3, 9))).to be_within(0.001).of(0.284)
    end
  end
end
