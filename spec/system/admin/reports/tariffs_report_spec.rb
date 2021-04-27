require 'rails_helper'

describe 'TariffsReport', type: :system, include_application_helper: true do

  let(:admin)                   { create(:admin) }
  let(:school_group)            { create(:school_group, name: 'Big Group') }
  let(:school)                  { create(:school, school_group: school_group) }
  let(:school_without_group)    { create(:school) }

  let!(:meter)                  { create(:electricity_meter, dcc_meter: true, school: school) }
  let!(:meter_without_group)    { create(:electricity_meter, dcc_meter: true, school: school_without_group) }

  let!(:standing_charge_1) { create(:tariff_standing_charge, meter: meter, value: 1.23, start_date: Date.parse('2020-01-01')) }
  let!(:standing_charge_2) { create(:tariff_standing_charge, meter: meter, value: 1.23, start_date: Date.parse('2020-01-02')) }

  let!(:price_1) { create(:tariff_price, meter: meter, tariff_date: Date.parse('2020-01-03'), prices: [1,2,3]) }
  let!(:price_2) { create(:tariff_price, meter: meter, tariff_date: Date.parse('2020-01-04'), prices: [1,2,3]) }

  before(:each) do
    sign_in(admin)
    visit root_path
    click_on 'Manage'
    click_on 'Reports'
  end

  it 'shows DCC meters with start and end dates of standing charges and prices' do
    click_on 'Tariffs report'

    expect(page).to have_content('Big Group')
    expect(page).to have_content(meter.mpan_mprn)
    expect(page).to have_content('2')
    expect(page).to have_content('Wed 1st Jan 2020')
    expect(page).to have_content('Thu 2nd Jan 2020')
    expect(page).to have_content('Fri 3rd Jan 2020')
    expect(page).to have_content('Sat 4th Jan 2020')

    expect(page).to have_content('Ungrouped')
    expect(page).to have_content(meter_without_group.mpan_mprn)
  end

  it 'shows individual DCC meter with values of standing charges and prices' do
    click_on 'Tariffs report'
    click_on meter.display_name

    expect(page).to have_content('Standing charges')
    expect(page).to have_content('Prices')

    expect(page).to have_content('1.23')
    expect(page).to have_content('[1, 2, 3]')
  end

  it 'links to meter attributes page' do
    click_on 'Tariffs report'
    click_on meter.display_name
    click_on 'Meter attributes'

    expect(page).to have_content('Individual Meter attributes')
    expect(page).to have_link('DCC tariff data')
  end
end
