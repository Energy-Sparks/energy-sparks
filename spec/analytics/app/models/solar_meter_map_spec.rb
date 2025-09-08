# frozen_string_literal: true

require 'rails_helper'

describe SolarMeterMap do
  let(:solar_pv_mpan_meter_mapping) do
    {
      start_date: Date.new(2017, 1, 1),
      end_date: Date.new(2017, 2, 2),
      export_mpan: '123456',
      production_mpan: '10123457',
      production_mpan2: '20123457',
      production_mpan3: '30123457',
      production_mpan4: '40123457',
      production_mpan5: '50123457',
      self_consume_mpan: '123458'
    }
  end

  describe '.meter_mappings' do
    it 'returns just the export and production meter mappings' do
      expect(described_class.meter_mappings(solar_pv_mpan_meter_mapping)).to eq(
        {
          export_mpan: '123456',
          production_mpan: '10123457',
          production_mpan2: '20123457',
          production_mpan3: '30123457',
          production_mpan4: '40123457',
          production_mpan5: '50123457'
        }
      )
    end
  end

  describe '.meter_type' do
    it 'returns the expected values' do
      expect(described_class.meter_type(:export_mpan)).to eq(:export)
      expect(described_class.meter_type(:production_mpan)).to eq(:generation)
      expect(described_class.meter_type(:production_mpan2)).to eq(:generation2)
      expect(described_class.meter_type(:production_mpan3)).to eq(:generation3)
      expect(described_class.meter_type(:production_mpan4)).to eq(:generation4)
      expect(described_class.meter_type(:production_mpan5)).to eq(:generation5)
    end
  end

  describe '.meter_attribute_key' do
    it 'returns the expected values' do
      expect(described_class.meter_attribute_key(:export)).to eq(:export_mpan)
      expect(described_class.meter_attribute_key(:generation)).to eq(:production_mpan)
      expect(described_class.meter_attribute_key(:generation2)).to eq(:production_mpan2)
      expect(described_class.meter_attribute_key(:generation3)).to eq(:production_mpan3)
      expect(described_class.meter_attribute_key(:generation4)).to eq(:production_mpan4)
      expect(described_class.meter_attribute_key(:generation5)).to eq(:production_mpan5)
    end
  end

  describe '#number_of_generation_meters' do
    subject(:solar_meter_map) do
      SolarMeterMap.instance
    end

    it 'returns number of generation meters' do
      expect(solar_meter_map.number_of_generation_meters).to eq(0)
      solar_meter_map[:generation] = build(:meter)
      expect(solar_meter_map.number_of_generation_meters).to eq(1)
      solar_meter_map[:generation2] = build(:meter)
      solar_meter_map[:generation3] = build(:meter)
      solar_meter_map[:generation4] = build(:meter)
      solar_meter_map[:generation5] = build(:meter)
      expect(solar_meter_map.number_of_generation_meters).to eq(5)
    end
  end
end
