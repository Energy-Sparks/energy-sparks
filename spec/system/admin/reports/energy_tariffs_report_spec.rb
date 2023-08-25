require 'rails_helper'

describe 'TariffsReport', type: :system do

  let(:admin)                    { create(:admin) }
  let!(:school_group)            { create(:school_group) }
  let!(:school)                  { create(:school, school_group: school_group) }
  let!(:school_2)                { create(:school, school_group: school_group) }

  let!(:group_tariffs)           { create_list(:energy_tariff, 3, tariff_holder: school_group) }
  let!(:school_tariff)           { create(:energy_tariff, tariff_holder: school, source: :manually_entered) }
  let!(:school_tariff_2)         { create(:energy_tariff, tariff_holder: school_2, source: :manually_entered) }

  let!(:school_dcc_tariff)       { create(:energy_tariff, tariff_holder: school, source: :dcc) }

  before(:each) do
    sign_in(admin)
    visit root_path
    click_on 'Manage'
    click_on 'Reports'
  end

  it 'displays a report' do
    click_on 'Energy Tariffs'
    expect(page).to have_link(school_group.name, href: school_group_energy_tariffs_path(school_group))
    expect(page).to have_link("3", href: school_group_energy_tariffs_path(school_group))
    expect(page).to have_link("1", href: admin_reports_tariffs_path(anchor: school_group.name.parameterize))
    expect(page).to have_content("2")
  end
end
