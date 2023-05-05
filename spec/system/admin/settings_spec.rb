require 'rails_helper'

describe 'site-wide settings' do

  let!(:admin)  { create(:admin)}

  before do
    sign_in(admin)
    visit root_path
    click_on 'Admin'
  end

  it 'allows admmins to update site settings with the site settings pricing feature flag enabled' do
    ClimateControl.modify FEATURE_FLAG_USE_SITE_SETTINGS_CURRENT_PRICES: 'true' do
      BenchmarkMetrics.set_current_prices(prices: BenchmarkMetrics.default_prices)
      expect(SiteSettings.current.electricity_price).to eq(nil)
      click_on 'Site Settings'
      uncheck 'Message for no contacts'
      uncheck 'October'
      check 'May'
      fill_in "Electricity price", with: 0.99
      fill_in "Solar export price", with: 0.98
      fill_in "Gas price", with: 0.97
      fill_in "Oil price", with: 0.96
      expect(BenchmarkMetrics.pricing).to eq(BenchmarkMetrics.default_prices)
      click_on 'Update settings'
      expect(SiteSettings.current.message_for_no_contacts).to eq(false)
      expect(SiteSettings.current.temperature_recording_month_numbers).to match_array([11, 12, 1, 2, 3, 4, 5])
      expect(SiteSettings.current.electricity_price).to eq(0.99)
      expect(SiteSettings.current.solar_export_price).to eq(0.98)
      expect(SiteSettings.current.gas_price).to eq(0.97)
      expect(SiteSettings.current.oil_price).to eq(0.96)
      expect(BenchmarkMetrics.pricing).not_to eq(BenchmarkMetrics.default_prices)
      expect(BenchmarkMetrics.pricing).to eq(OpenStruct.new(gas_price: 0.97, oil_price: 0.96, electricity_price: 0.99, solar_export_price: 0.98))
    end
  end

  it 'allows admmins to update site settings with the site settings pricing feature flag disabled' do
    ClimateControl.modify FEATURE_FLAG_USE_SITE_SETTINGS_CURRENT_PRICES: 'false' do
      BenchmarkMetrics.set_current_prices(prices: BenchmarkMetrics.default_prices)
      expect(SiteSettings.current.electricity_price).to eq(nil)
      click_on 'Site Settings'
      uncheck 'Message for no contacts'
      uncheck 'October'
      check 'May'
      expect(page).to_not have_content('Electricity price')
      expect(page).to_not have_content('Solar export price')
      expect(page).to_not have_content('Gas price')
      expect(page).to_not have_content('Oil price')
      expect(BenchmarkMetrics.pricing).to eq(BenchmarkMetrics.default_prices)
      click_on 'Update settings'
      expect(SiteSettings.current.message_for_no_contacts).to eq(false)
      expect(SiteSettings.current.temperature_recording_month_numbers).to match_array([11, 12, 1, 2, 3, 4, 5])
      expect(SiteSettings.current.electricity_price).to eq(nil)
      expect(SiteSettings.current.solar_export_price).to eq(nil)
      expect(SiteSettings.current.gas_price).to eq(nil)
      expect(SiteSettings.current.oil_price).to eq(nil)
      expect(BenchmarkMetrics.pricing).to eq(BenchmarkMetrics.default_prices)
    end
  end
end
