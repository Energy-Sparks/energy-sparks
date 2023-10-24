require 'rails_helper'

describe 'TariffsReport', type: :system, include_application_helper: true do
  let(:admin)                   { create(:admin) }
  let(:school_group)            { create(:school_group, name: 'Big Group') }
  let(:school)                  { create(:school, school_group: school_group) }
  let(:school_without_group)    { create(:school) }

  let!(:meter)                  { create(:electricity_meter, dcc_meter: true, school: school) }

  let!(:meter_without_group)    { create(:electricity_meter, dcc_meter: true, school: school_without_group) }

  # let!(:standing_charge_1) { create(:tariff_standing_charge, meter: meter, value: 1.23, start_date: Date.parse('2020-01-01')) }
  # let!(:standing_charge_2) { create(:tariff_standing_charge, meter: meter, value: 1.23, start_date: Date.parse('2020-01-02')) }

  # let!(:price_1) { create(:tariff_price, meter: meter, tariff_date: Date.parse('2020-01-03'), prices: [1,2,3]) }
  # let!(:price_2) { create(:tariff_price, meter: meter, tariff_date: Date.parse('2020-01-04'), prices: [1,2,3]) }

  let(:energy_tariff_1) { EnergyTariff.create(name: 'My Tariff', meter_type: :gas, start_date: '2018-01-01', end_date: '2018-12-31', tariff_holder_type: "School", school: school, tariff_type: 'differential')}
  let(:energy_tariff_2) { EnergyTariff.create(name: 'My Tariff', meter_type: :gas, start_date: '2019-01-01', end_date: '2019-12-31', tariff_holder_type: "School", school: school, tariff_type: 'differential')}
  let(:energy_tariff_3) { EnergyTariff.create(name: 'My Tariff', meter_type: :gas, start_date: '2020-01-01', end_date: '2020-12-31', tariff_holder_type: "School", school: school, tariff_type: 'differential')}
  let(:energy_tariff_4) { EnergyTariff.create(name: 'My Tariff', meter_type: :gas, start_date: '2021-01-01', end_date: '2021-12-31', tariff_holder_type: "School", school: school_without_group, tariff_type: 'differential')}

  before do
    meter.update!(energy_tariffs: [energy_tariff_1, energy_tariff_2, energy_tariff_3])
    meter_without_group.update!(energy_tariffs: [energy_tariff_4])
    sign_in(admin)
    visit root_path
    click_on 'Manage'
    click_on 'Reports'
  end

  it 'shows DCC meters with start and end dates of standing charges and prices' do
    click_on 'Tariffs report'

    expect(page).to have_content('Big Group')
    expect(page).to have_content(meter.mpan_mprn)
    expect(page).to have_content('3')
    expect(page).to have_content('Rate from 01/01/2018 to 31/12/2018')
    expect(page).to have_content('Rate from 01/01/2020 to 31/12/2020')

    expect(page).to have_content('Ungrouped')
    expect(page).to have_content(meter_without_group.mpan_mprn)
    expect(page).to have_content('Rate from 01/01/2021 to 31/12/2021')
  end

  it 'shows sub nav' do
    click_on 'Tariffs report'
    click_on meter.display_name

    expect(page).to have_link('Manage School')
  end

  it 'links to smart meter tariffs page' do
    click_on 'Tariffs report'
    click_on meter.display_name
    expect(page).to have_current_path("/schools/#{school.slug}/energy_tariffs/smart_meter_tariffs")

    expect(page).to have_content('Manage and view tariffs')
    expect(page).to have_content('We are automatically loading basic tariff information from your smart meters')
  end
end
