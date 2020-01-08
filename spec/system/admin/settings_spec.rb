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
    click_on 'Update settings'

    expect(SiteSettings.current.message_for_no_contacts).to eq(false)

  end

end
