require 'rails_helper'

describe SiteSettings do
  describe '#current' do
    it 'returns the newest site setting record' do
      3.times { SiteSettings.create!(electricity_price: 1, solar_export_price: 1, gas_price: 1) }
      expect(SiteSettings.count).to eq(3)
      expect(SiteSettings.current).to eq(SiteSettings.order(:created_at).last)
    end
  end

  describe '#temperature_recording_month_numbers' do
    it 'returns temperature recording months as a compacted array of integers' do
      SiteSettings.create!(electricity_price: 1, solar_export_price: 1, gas_price: 1, temperature_recording_months: ['10', nil, '12', '1', '2', nil, '4'])
      expect(SiteSettings.current.temperature_recording_month_numbers).to eq([10, 12, 1, 2, 4])
    end
  end

  describe 'prices' do
    it 'validates values for all price fields are floats' do
      site_setting = SiteSettings.new(electricity_price: 1, solar_export_price: 1, gas_price: 1)

      site_setting.electricity_price = 'not a float'
      expect(site_setting).not_to be_valid
      site_setting.electricity_price = nil
      expect(site_setting).not_to be_valid
      site_setting.electricity_price = 1.0
      expect(site_setting).to be_valid

      site_setting.solar_export_price = 'not a float'
      expect(site_setting).not_to be_valid
      site_setting.solar_export_price = nil
      expect(site_setting).not_to be_valid
      site_setting.solar_export_price = 1.0
      expect(site_setting).to be_valid

      site_setting.gas_price = 'not a float'
      expect(site_setting).not_to be_valid
      site_setting.gas_price = nil
      expect(site_setting).not_to be_valid
      site_setting.gas_price = 1.0
      expect(site_setting).to be_valid
    end
  end

  describe '#current_prices' do
    it 'returns an openstruct of all current price values' do
      (1..3).each { |i| SiteSettings.create!(electricity_price: i.to_f, solar_export_price: i.to_f, gas_price: i.to_f) }
      expect(SiteSettings.current).to eq(SiteSettings.order(:created_at).last)
      expect(SiteSettings.current_prices.class).to eq(OpenStruct)
      expect(SiteSettings.current_prices.to_h).to eq({ gas_price: 3.0, electricity_price: 3.0, solar_export_price: 3.0 })
    end
  end
end
