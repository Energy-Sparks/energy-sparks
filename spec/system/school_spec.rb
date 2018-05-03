require 'rails_helper'

RSpec.describe "school", type: :system do

  let(:school_name) { 'Oldfield Park Infants'}
  let!(:school) { create(:school, name: school_name)}
  let!(:admin) { create(:user, role: 'admin')}

  it 'shows me a school page' do
    visit root_path
    click_on('Schools')
    expect(page.has_content? "Participating Schools")
    click_on(school_name)
    expect(page.has_content? school_name)
  end

  it 'I can set up a school' do

    login_as(admin)
    visit root_path
    expect(page.has_content? 'Sign out')
    click_on('Schools')
    expect(page.has_content? "Participating Schools")
    click_on(school_name)
    expect(page.has_content? 'Edit')
    click_on('Edit')
    # fill_in(id: :school_meters_attributes_0_meter_no, with: 12345)
    # fill_in(id: :school_meters_attributes_0_name).with('Test meter')
    # select('Electricity', from: 'Type')

  end
end
