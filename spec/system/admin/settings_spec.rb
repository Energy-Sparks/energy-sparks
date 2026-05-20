require 'rails_helper'

describe 'site-wide settings' do
  let!(:admin) { create(:admin)}

  before do
    sign_in(admin)
    visit root_path
    click_on 'Admin'
  end

  context 'with pricing feature flag enabled' do
    around do |example|
      example.run
      BenchmarkMetrics.set_current_prices(prices: BenchmarkMetrics.default_prices)
    end

    context 'with no existing site settings' do
      it 'allows admins to update site settings with prices' do
        click_on 'Site Settings'
        uncheck 'Message for no contacts'
        uncheck 'October'
        check 'May'
        fill_in 'Electricity price', with: 0.99
        fill_in 'Solar export price', with: 0.98
        fill_in 'Gas price', with: 0.97
        expect(BenchmarkMetrics.pricing).to eq(BenchmarkMetrics.default_prices)
        click_on 'Update settings'
        expect(SiteSettings.count).to eq 1
        expect(SiteSettings.current.message_for_no_contacts).to eq(false)
        expect(SiteSettings.current.temperature_recording_month_numbers).to match_array([11, 12, 1, 2, 3, 4, 5])
        expect(SiteSettings.current.electricity_price).to eq(0.99)
        expect(SiteSettings.current.solar_export_price).to eq(0.98)
        expect(SiteSettings.current.gas_price).to eq(0.97)
        expect(BenchmarkMetrics.pricing).not_to eq(BenchmarkMetrics.default_prices)
        expect(BenchmarkMetrics.pricing).to eq(OpenStruct.new(gas_price: 0.97, electricity_price: 0.99, solar_export_price: 0.98))
      end
    end

    context 'with site settings' do
      before do
        SiteSettings.create!(message_for_no_contacts: false, electricity_price: 1.2, gas_price: 0.2, solar_export_price: 0.1, temperature_recording_months: [1, 2, 3, 4, 5])
      end

      it 'updates price' do
        click_on 'Site Settings'
        check 'Message for no contacts'
        fill_in 'Electricity price', with: 0.99
        fill_in 'Solar export price', with: 0.98
        fill_in 'Gas price', with: 0.97
        click_on 'Update settings'
        expect(SiteSettings.count).to eq 1
        expect(SiteSettings.current.electricity_price).to eq(0.99)
        expect(SiteSettings.current.solar_export_price).to eq(0.98)
        expect(SiteSettings.current.gas_price).to eq(0.97)
        expect(SiteSettings.current.message_for_no_contacts).to eq(true)
        expect(SiteSettings.current.temperature_recording_month_numbers).to match_array([1, 2, 3, 4, 5])
      end

      context 'that have tariffs' do
        let!(:tariff) { create(:energy_tariff, :with_flat_price, tariff_holder: SiteSettings.current)}

        it 'updates price' do
          click_on 'Site Settings'
          fill_in 'Electricity price', with: 0.99
          click_on 'Update settings'
          expect(SiteSettings.count).to eq 1
          expect(SiteSettings.current.electricity_price).to eq(0.99)
          expect(SiteSettings.current.energy_tariffs.first).to eq tariff
        end
      end
    end
  end
end
