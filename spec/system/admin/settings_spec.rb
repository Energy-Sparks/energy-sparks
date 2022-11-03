require 'rails_helper'

describe 'site-wide settings' do

  let!(:admin)  { create(:admin)}

  before do
    sign_in(admin)
    visit root_path
    click_on 'Admin'
  end

  it 'allows admmins to update site settings' do
    expect(SiteSettings.current.electricity_price).to eq(nil)

    click_on 'Site Settings'
    uncheck 'Message for no contacts'

    uncheck 'October'
    check 'May'

    fill_in "Electricity price", with: 0.99
    fill_in "Solar export price", with: 0.98
    fill_in "Gas price", with: 0.97
    fill_in "Oil price", with: 0.96

    click_on 'Update settings'

    expect(SiteSettings.current.message_for_no_contacts).to eq(false)
    expect(SiteSettings.current.temperature_recording_month_numbers).to match_array([11, 12, 1, 2, 3, 4, 5])
    expect(SiteSettings.current.electricity_price).to eq(0.99)
    expect(SiteSettings.current.solar_export_price).to eq(0.98)
    expect(SiteSettings.current.gas_price).to eq(0.97)
    expect(SiteSettings.current.oil_price).to eq(0.96)
  end
end
