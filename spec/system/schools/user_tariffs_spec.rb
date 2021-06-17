require 'rails_helper'

describe 'user tariffs', type: :system do

  let!(:school)                   { create_active_school(name: "Big School")}
  let!(:admin)                    { create(:admin) }
  let!(:electricity_meter)        { create(:electricity_meter, school: school, mpan_mprn: '12345678901234') }

  context 'as an admin' do

    before(:each) do
      sign_in(admin)
      visit school_path(school)
    end

    context 'creating electricity tariffs' do

      it 'can create a tariff and add prices and charges' do
        click_link('Manage tariffs')

        expect(page).to have_content('All tariffs')

        click_link('Add electricity tariff')

        expect(page).to have_content('Select meters for tariff')
        check('12345678901234')
        click_button('Next')

        expect(page).to have_content('Add electricity tariff')

        fill_in 'Name', with: 'My First Tariff'
        click_button('Next')

        expect(page).to have_content('Edit electricity tariff')
        click_button('Economy 7')

        expect(page).to have_content('Tariff rates')
        expect(page).to have_content('My First Tariff electricity for 2021-04-01 to 2022-03-31')

        click_link('Add rate')
        expect(page).to have_content('Add tariff rate')
        fill_in 'Start time', with: '00:00'
        fill_in 'End time', with: '07:00'
        fill_in 'Value in £/kWh', with: '1.23'
        click_button('Save')

        expect(page).to have_content('Tariff rates')
        expect(page).to have_content('00:00')
        expect(page).to have_content('07:00')
        expect(page).to have_content('1.23 £/kWh')

        click_link('Next')

        expect(page).to have_content('Tariff standing charges')
        expect(page).to have_content('My First Tariff electricity for 2021-04-01 to 2022-03-31')

        click_link('Add standing charge')
        expect(page).to have_content('Add tariff standing charge')
        select 'Fixed charge', from: 'Charge type'
        fill_in 'Value', with: '4.56'
        select 'kVA', from: 'Units'
        click_button('Save')

        click_link('Next')
        expect(page).to have_content('Review tariff')
        expect(page).to have_content('1.23 £/kWh')
        expect(page).to have_content('4.56 per kVA')
        expect(page).not_to have_link('Delete')

        click_link('Finished')
        expect(page).to have_content('All tariffs')
        expect(page).to have_content('12345678901234')

        expect(UserTariff.last.meters).to match_array([electricity_meter])
      end

    end

  end
end
