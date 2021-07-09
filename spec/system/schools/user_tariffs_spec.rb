require 'rails_helper'

describe 'user tariffs', type: :system do

  let!(:school)                   { create_active_school(name: "Big School")}
  let!(:admin)                    { create(:admin) }
  let!(:electricity_meter)        { create(:electricity_meter, school: school, mpan_mprn: '12345678901234') }
  let!(:gas_meter)                { create(:gas_meter, school: school, mpan_mprn: '999888777') }

  context 'as a school admin' do
    let!(:school_admin)                    { create(:school_admin, school: school) }

    before(:each) do
      sign_in(school_admin)
    end

    it 'menu item is not there' do
      visit school_path(school)
      expect(page).not_to have_link('Manage tariffs')
    end

    it 'access is denied' do
      visit school_user_tariffs_path(school)
      expect(page).to have_content('not authorized')
      expect(page).to have_content('Management Dashboard')
    end
  end

  context 'as an admin' do

    before(:each) do
      sign_in(admin)
    end

    context 'creating flat rate gas tariffs' do

      it 'can create a tariff and add prices and charges' do
        visit school_path(school)
        click_link('Manage tariffs')

        expect(page).to have_content('All tariffs')

        click_link('Add gas tariff')

        expect(page).to have_content('Select meters for tariff')
        check('999888777')
        click_button('Next')

        expect(page).to have_content('Add gas tariff')

        fill_in 'Name', with: 'My First Gas Tariff'
        click_button('Next')

        expect(page).to have_content('Energy charges')
        expect(page).to have_content('My First Gas Tariff (gas, 01/04/2021 to 31/03/2022)')
        expect(page).to have_content('999888777')

        fill_in "user_tariff_price[value]", with: '1.5'
        click_button('Next')

        expect(page).to have_content('Standing charges')
        expect(page).to have_content('My First Gas Tariff (gas, 01/04/2021 to 31/03/2022)')
        expect(page).to have_content('999888777')

        fill_in "user_tariff_charges[fixed_charge][value]", with: '4.56'
        select 'month', from: 'user_tariff_charges[fixed_charge][units]'
        check 'user_tariff_charges[user_tariff][ccl]'
        select '5%', from: 'user_tariff_charges[user_tariff][vat_rate]'

        click_button('Next')

        expect(page).to have_content('Please review')
        expect(page).to have_content('999888777')
        expect(page).to have_content('5%')
        expect(page).to have_content('Flat rate tariff')
        expect(page).to have_content('£1.50 per kWh')
        expect(page).to have_content('£4.56 per month')
        expect(page).not_to have_link('Delete')

        click_link('Finished')
        expect(page).to have_content('All tariffs')
        expect(page).to have_content('999888777')
        expect(page).to have_content('5%')

        user_tariff = UserTariff.last
        expect(user_tariff.meters).to match_array([gas_meter])
        expect(user_tariff.vat_rate).to eq('5%')
        expect(user_tariff.ccl).to be_truthy
        user_tariff_price = user_tariff.user_tariff_prices.first
        expect(user_tariff_price.start_time.to_s(:time)).to eq('00:00')
        expect(user_tariff_price.end_time.to_s(:time)).to eq('23:30')
        expect(user_tariff_price.units).to eq('kwh')
      end
    end

    context 'creating flat rate electricity tariffs' do

      it 'can handle partially created tariff with bits missing' do
        visit school_path(school)
        click_link('Manage tariffs')

        expect(page).to have_content('All tariffs')

        click_link('Add electricity tariff')

        expect(page).to have_content('Select meters for tariff')
        expect(page).to have_content(electricity_meter.mpan_mprn)
        expect(page).not_to have_content(gas_meter.mpan_mprn)

        click_button('Next')

        expect(page).to have_content('Add electricity tariff')
        fill_in 'Name', with: 'My First Flat Tariff'
        click_button('Next')
        click_button('Simple')

        visit school_user_tariffs_path(school)

        expect(page).to have_content('All tariffs')
        expect(page).to have_content('No flat rate tariff has been set yet')
        expect(page).to have_content('There are no meters associated with this tariff')
      end

      it 'can create a flat rate tariff with price' do
        visit school_path(school)
        click_link('Manage tariffs')
        click_link('Add electricity tariff')

        check('12345678901234')
        click_button('Next')

        fill_in 'Name', with: 'My First Flat Tariff'
        click_button('Next')

        click_button('Simple')

        fill_in "user_tariff_price[value]", with: '1.5'
        click_button('Next')

        click_button('Next')

        expect(page).to have_content('Please review')
        expect(page).to have_content('Flat rate tariff')
        expect(page).to have_content('£1.50 per kWh')
        expect(page).not_to have_link('Delete')

        click_link('Finished')
        expect(page).to have_content('All tariffs')
        expect(page).to have_content('12345678901234')

        user_tariff = UserTariff.last
        expect(user_tariff.meters).to match_array([electricity_meter])
        expect(user_tariff.flat_rate).to be_truthy
        expect(user_tariff.vat_rate).to eq('0%')
        expect(user_tariff.ccl).to be_falsey
        user_tariff_price = user_tariff.user_tariff_prices.first
        expect(user_tariff_price.start_time.to_s(:time)).to eq('00:00')
        expect(user_tariff_price.end_time.to_s(:time)).to eq('23:30')
        expect(user_tariff_price.value.to_s).to eq('1.5')
        expect(user_tariff_price.units).to eq('kwh')
      end
    end

    context 'creating differential electricity tariffs' do

      it 'can create a tariff and add prices and charges' do
        visit school_path(school)
        click_link('Manage tariffs')
        click_link('Add electricity tariff')

        check('12345678901234')
        click_button('Next')

        fill_in 'Name', with: 'My First Diff Tariff'
        click_button('Next')

        click_button('Day/Night tariff')

        click_link('Add rate')

        select '00', from: 'user_tariff_price_start_time_4i'
        select '00', from: 'user_tariff_price_start_time_5i'
        select '07', from: 'user_tariff_price_end_time_4i'
        select '00', from: 'user_tariff_price_end_time_5i'

        fill_in 'Rate in £/kWh', with: '1.5'
        click_button('Save')

        expect(page).to have_content('00:00')
        expect(page).to have_content('07:00')
        expect(page).to have_content('£1.50 per kWh')

        click_link('Next')
        click_button('Next')

        expect(page).to have_content('Please review')
        expect(page).to have_content('£1.50 per kWh')
        expect(page).not_to have_link('Delete')

        click_link('Finished')
        expect(page).to have_content('All tariffs')
        expect(page).to have_content('12345678901234')

        user_tariff = UserTariff.last
        expect(user_tariff.meters).to match_array([electricity_meter])
        user_tariff_price = user_tariff.user_tariff_prices.first
        expect(user_tariff_price.start_time.to_s(:time)).to eq('00:00')
        expect(user_tariff_price.end_time.to_s(:time)).to eq('07:00')
        expect(user_tariff_price.value.to_s).to eq('1.5')
        expect(user_tariff_price.units).to eq('kwh')
      end
    end

    context 'adding electricity standing charges' do

      it 'can create a tariff and add charges' do
        visit school_path(school)
        click_link('Manage tariffs')
        click_link('Add electricity tariff')

        check('12345678901234')
        click_button('Next')

        fill_in 'Name', with: 'My First Diff Tariff'
        click_button('Next')

        click_button('Simple')

        fill_in "user_tariff_price[value]", with: '1.5'
        click_button('Next')

        fill_in "user_tariff_charges[fixed_charge][value]", with: '1.11'
        select 'day', from: 'user_tariff_charges[fixed_charge][units]'

        fill_in "user_tariff_charges[site_fee][value]", with: '2.22'
        select 'month', from: 'user_tariff_charges[site_fee][units]'

        fill_in "user_tariff_charges[duos_red][value]", with: '3.33'
        fill_in "user_tariff_charges[duos_amber][value]", with: '4.44'
        fill_in "user_tariff_charges[duos_green][value]", with: '5.55'

        check 'user_tariff_charges[user_tariff][tnuos]'
        check 'user_tariff_charges[user_tariff][ccl]'
        select '20%', from: 'user_tariff_charges[user_tariff][vat_rate]'

        click_button('Next')
        expect(page).to have_content('Please review')
        expect(page).to have_content('£1.50 per kWh')
        expect(page).to have_content('£1.11 per day')
        expect(page).to have_content('£2.22 per month')
        expect(page).to have_content('3.33')
        expect(page).to have_content('4.44')
        expect(page).to have_content('5.55')

        user_tariff = UserTariff.last
        expect(user_tariff.tnuos).to be_truthy
        expect(user_tariff.ccl).to be_truthy
        expect(user_tariff.vat_rate).to eq('20%')
      end
    end

    context 'with existing user tariff' do

      let!(:user_tariff)  do
        UserTariff.create(
          school: school,
          start_date: '01/04/2021',
          end_date: '31/03/2022',
          name: 'My First Tariff',
          fuel_type: :electricity,
          flat_rate: true,
          vat_rate: '20%',
          ccl: true,
          user_tariff_prices: [user_tariff_price],
          user_tariff_charges: [user_tariff_charge],
          meters: [electricity_meter]
        )
      end

      let(:user_tariff_price)  { UserTariffPrice.new(start_time: '00:00', end_time: '23:30', value: 1.23, units: 'kwh') }
      let(:user_tariff_charge)  { UserTariffCharge.new(charge_type: :fixed_charge, value: 4.56, units: :month) }

      it 'shows meter attributes on the meter attributes page' do
        visit admin_school_single_meter_attribute_path(school, electricity_meter)

        expect(page).to have_content('My First Tariff')
        expect(page).to have_content('manually_entered')
        expect(page).to have_content('Thu, 01 Apr 2021')
        expect(page).to have_content('Thu, 31 Mar 2022')
        expect(page).to have_content('1.23')
        expect(page).to have_content(':kwh')
        expect(page).to have_content('4.56')
        expect(page).to have_content(':month')
      end
    end
  end
end
