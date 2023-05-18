require 'rails_helper'

describe 'site-wide settings' do

  let!(:admin)  { create(:admin)}

  before do
    sign_in(admin)
    visit root_path
    click_on 'Admin'
  end

  it 'allows admmins to update site settings' do
    click_on 'Site Settings'
    uncheck 'Message for no contacts'

    uncheck 'October'
    check 'May'

    click_on 'Update settings'

    expect(SiteSettings.current.message_for_no_contacts).to eq(false)
    expect(SiteSettings.current.temperature_recording_month_numbers).to match_array([11, 12, 1, 2, 3, 4, 5])

  end

end
