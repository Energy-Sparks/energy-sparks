require 'rails_helper'

describe 'Solar Panels Report', type: :system do
  let(:admin) { create(:admin) }
  let!(:solar_panels) { create(:solar_pv_attribute) }

  before do
    sign_in(admin)
    visit root_path
    click_on 'Manage'
    click_on 'Reports'
  end

  it 'displays a report' do
    click_on 'Solar panels'
    expect(page).to have_link(solar_panels.meter.school.name, href: school_path(solar_panels.meter.school))
    expect(page).to have_link(solar_panels.meter.name, href: school_meter_path(solar_panels.meter.school, solar_panels.meter))
    expect(page).to have_content(solar_panels.input_data['start_date'])
    expect(page).to have_content(solar_panels.input_data['end_date'])
    expect(page).to have_content(solar_panels.input_data['kwp'])
    expect(page).to have_link('Edit', href: edit_admin_school_meter_attribute_path(solar_panels.meter.school, id: solar_panels.id))
  end
end
