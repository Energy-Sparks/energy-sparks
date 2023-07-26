require 'rails_helper'

describe 'energy tariffs', type: :system do

  let!(:school)                   { create_active_school(name: "Big School")}
  let!(:school_admin)             { create(:school_admin, school: school) }
  let!(:electricity_meter)        { create(:electricity_meter, school: school, mpan_mprn: '12345678901234') }
  let!(:gas_meter)                { create(:gas_meter, school: school, mpan_mprn: '999888777') }

  around do |example|
    ClimateControl.modify FEATURE_FLAG_USE_NEW_ENERGY_TARIFFS: 'true' do
      example.run
    end
  end

  context 'as an admin' do
    let!(:admin)                    { create(:admin) }

    before(:each) do
      sign_in(admin)
    end

    context 'has navigation links' do
      it 'from meters page to user tariffs index' do
        visit school_meters_path(school)
        click_link('Manage School')
        click_link('Manage tariffs')
        expect(current_path).to eq("/schools/#{school.slug}/energy_tariffs")
        expect(page).to have_content(I18n.t('schools.user_tariffs.index.title'))
        expect(page).to have_link('cost analysis pages')
      end
    end
  end

  context 'as a school admin' do

    before(:each) do
      sign_in(school_admin)
    end

    context 'creating flat rate gas tariffs' do
      it 'can create a tariff and add prices and charges' do
        visit school_path(school)
        click_link('Manage tariffs')
        expect(current_path).to eq("/schools/big-school/energy_tariffs")

        expect(page).to have_content('Manage tariffs')

        click_link('Add gas tariff')

        expect(page).to have_content('Select meters for this tariff')
        check('999888777')
        click_button('Next')

        expect(page).to have_content('Choose a name and date range')

        fill_in 'Name', with: 'My First Gas Tariff'
        click_button('Next')

        expect(page).to have_content('Add consumption charges')
        expect(page).to have_content('01/04/2021 to 31/03/2022 : My First Gas Tariff')
        expect(page).to have_content('999888777')

        fill_in "energy_tariff_price[value]", with: '1.5'
        click_button('Next')

        expect(page).to have_content('Add standing charges')
        expect(page).to have_content('01/04/2021 to 31/03/2022 : My First Gas Tariff')
        expect(page).to have_content('999888777')

        fill_in "energy_tariff_charges[fixed_charge][value]", with: '4.56'
        select 'month', from: 'energy_tariff_charges[fixed_charge][units]'
        check 'energy_tariff_charges[energy_tariff][ccl]'
        select '5%', from: 'energy_tariff_charges[energy_tariff][vat_rate]'

        click_button('Next')

        expect(page).to have_content('Tariff details')
        expect(page).to have_content('999888777')
        expect(page).to have_content('5%')
        expect(page).to have_content('Flat rate tariff')
        expect(page).to have_content('£1.50 per kWh')
        expect(page).to have_content('£4.56 per month')
        expect(page).not_to have_link('Delete')

        click_link('Finished')
        expect(page).to have_content('Manage tariffs')
        expect(page).to have_content('999888777')

        energy_tariff = EnergyTariff.last
        expect(energy_tariff.meters).to match_array([gas_meter])
        expect(energy_tariff.vat_rate).to eq(5)
        expect(energy_tariff.ccl).to be_truthy
        energy_tariff_price = energy_tariff.energy_tariff_prices.first
        expect(energy_tariff_price.start_time.to_s(:time)).to eq('00:00')
        expect(energy_tariff_price.end_time.to_s(:time)).to eq('23:30')
        expect(energy_tariff_price.units).to eq('kwh')
      end
    end

    context 'creating flat rate electricity tariffs' do

      before(:each) do
        visit school_path(school)
        click_link('Manage tariffs')
      end

      it 'requires a meter to be selected' do
        click_link('Add electricity tariff')

        expect(page).to have_content('Select meters for this tariff')
        expect(page).to have_content(electricity_meter.mpan_mprn)
        uncheck(electricity_meter.mpan_mprn.to_s)
        click_button('Next')

        expect(page).to have_content('Select meters for this tariff')
        expect(page).to have_content('Please select at least one meter')
      end

      it 'can handle partially created tariff with bits missing' do
        expect(page).to have_content(I18n.t('schools.user_tariffs.index.title'))

        click_link('Add electricity tariff')

        expect(page).to have_content('Select meters for this tariff')
        expect(page).to have_content(electricity_meter.mpan_mprn)
        expect(page).not_to have_content(gas_meter.mpan_mprn)

        click_button('Next')

        expect(page).to have_content('Choose a name and date range')
        fill_in 'Name', with: 'My First Flat Tariff'
        click_button('Next')
        click_button('Simple')

        visit school_energy_tariffs_path(school)

        expect(page).to have_content(I18n.t('schools.user_tariffs.index.title'))
      end

      it 'can create a flat rate tariff with price' do
        click_link('Add electricity tariff')

        check('12345678901234')
        click_button('Next')

        fill_in 'Name', with: 'My First Flat Tariff'
        click_button('Next')

        click_button('Simple')

        fill_in "energy_tariff_price[value]", with: '1.5'
        click_button('Next')

        click_button('Next')

        expect(page).to have_content('Tariff details')
        expect(page).to have_content('Flat rate tariff')
        expect(page).to have_content('£1.50 per kWh')
        expect(page).not_to have_link('Delete')

        click_link('Finished')
        expect(page).to have_content('Manage tariffs')
        expect(page).to have_content('12345678901234')

        energy_tariff = EnergyTariff.last
        expect(energy_tariff.meters).to match_array([electricity_meter])
        expect(energy_tariff.tariff_type == 'flat_rate').to be_truthy
        expect(energy_tariff.vat_rate).to eq(0)
        expect(energy_tariff.ccl).to be_falsey
        energy_tariff_price = energy_tariff.energy_tariff_prices.first
        expect(energy_tariff_price.start_time.to_s(:time)).to eq('00:00')
        expect(energy_tariff_price.end_time.to_s(:time)).to eq('23:30')
        expect(energy_tariff_price.value.to_s).to eq('1.5')
        expect(energy_tariff_price.units).to eq('kwh')
      end
    end

    context 'creating differential electricity tariffs' do

      before(:each) do
        visit school_path(school)
        click_link('Manage tariffs')
      end

      it 'can create a tariff and add prices and charges' do
        click_link('Add electricity tariff')

        check('12345678901234')
        click_button('Next')

        fill_in 'Name', with: 'My First Diff Tariff'
        click_button('Next')

        click_button('Day/Night tariff')

        expect(page).to have_content('Night rate (00:00 to 07:00)')
        expect(page).to have_content('Day rate (07:00 to 00:00)')
        expect(page).not_to have_link('Add rate')
        expect(page).not_to have_link('Delete')

        first('.energy-tariff-show-button').click

        select '00', from: 'energy_tariff_price_start_time_4i'
        select '30', from: 'energy_tariff_price_start_time_5i'
        select '06', from: 'energy_tariff_price_end_time_4i'
        select '30', from: 'energy_tariff_price_end_time_5i'

        fill_in 'Rate in £/kWh', with: '1.5'
        click_button('Save')

        expect(page).to have_content('Night rate (00:30 to 06:30)')
        expect(page).to have_content('Day rate (07:00 to 00:00)')
        expect(page).to have_content('£1.50 per kWh')
        expect(page).to have_content('£0.00 per kWh')

        click_link('Next')
        click_button('Next')

        expect(page).to have_content('Tariff details')
        expect(page).to have_content('£1.50 per kWh')
        expect(page).not_to have_link('Delete')

        click_link('Finished')
        expect(page).to have_content('Manage tariffs')
        expect(page).to have_content('12345678901234')

        energy_tariff = EnergyTariff.last
        expect(energy_tariff.meters).to match_array([electricity_meter])
        energy_tariff_price = energy_tariff.energy_tariff_prices.first
        expect(energy_tariff_price.start_time.to_s(:time)).to eq('00:30')
        expect(energy_tariff_price.end_time.to_s(:time)).to eq('06:30')
        expect(energy_tariff_price.value.to_s).to eq('1.5')
        expect(energy_tariff_price.units).to eq('kwh')
        energy_tariff_price = energy_tariff.energy_tariff_prices.last
        expect(energy_tariff_price.start_time.to_s(:time)).to eq('07:00')
        expect(energy_tariff_price.end_time.to_s(:time)).to eq('00:00')
        expect(energy_tariff_price.value.to_s).to eq('0.0')
        expect(energy_tariff_price.units).to eq('kwh')
      end
    end

    context 'adding electricity standing charges' do

      before(:each) do
        visit school_path(school)
        click_link('Manage tariffs')
      end

      it 'can create a tariff and add charges' do
        click_link('Add electricity tariff')

        check('12345678901234')
        click_button('Next')

        fill_in 'Name', with: 'My First Diff Tariff'
        click_button('Next')

        click_button('Simple')

        fill_in "energy_tariff_price[value]", with: '1.5'
        click_button('Next')

        fill_in "energy_tariff_charges[fixed_charge][value]", with: '1.11'
        select 'day', from: 'energy_tariff_charges[fixed_charge][units]'

        fill_in "energy_tariff_charges[site_fee][value]", with: '2.22'
        select 'month', from: 'energy_tariff_charges[site_fee][units]'

        fill_in "energy_tariff_charges[duos_red][value]", with: '3.33'
        fill_in "energy_tariff_charges[duos_amber][value]", with: '4.44'
        fill_in "energy_tariff_charges[duos_green][value]", with: '5.55'

        fill_in "energy_tariff_charges[agreed_availability_charge][value]", with: '6.66'
        fill_in "energy_tariff_charges[excess_availability_charge][value]", with: '7.77'
        fill_in "energy_tariff_charges[asc_limit_kw][value]", with: '8.88'

        fill_in "energy_tariff_charges[reactive_power_charge][value]", with: '9.99'
        fill_in "energy_tariff_charges[feed_in_tariff_levy][value]", with: '9.87'

        fill_in "energy_tariff_charges[settlement_agency_fee][value]", with: '6.54'
        fill_in "energy_tariff_charges[meter_asset_provider_charge][value]", with: '3.21'
        fill_in "energy_tariff_charges[nhh_metering_agent_charge][value]", with: '1.9'

        fill_in "energy_tariff_charges[nhh_automatic_meter_reading_charge][value]", with: '.12'
        fill_in "energy_tariff_charges[data_collection_dcda_agent_charge][value]", with: '.34'

        check 'energy_tariff_charges[energy_tariff][tnuos]'
        check 'energy_tariff_charges[energy_tariff][ccl]'
        select '20%', from: 'energy_tariff_charges[energy_tariff][vat_rate]'

        click_button('Next')
        expect(page).to have_content('Tariff details')

        energy_tariff = EnergyTariff.last
        expect(energy_tariff.tnuos).to be_truthy
        expect(energy_tariff.ccl).to be_truthy
        expect(energy_tariff.vat_rate).to eq(20)

        expect(energy_tariff.value_for_charge(:fixed_charge)).to eq('1.11')
        expect(energy_tariff.value_for_charge(:site_fee)).to eq('2.22')
        expect(energy_tariff.value_for_charge(:duos_red)).to eq('3.33')
        expect(energy_tariff.value_for_charge(:duos_amber)).to eq('4.44')
        expect(energy_tariff.value_for_charge(:duos_green)).to eq('5.55')
        expect(energy_tariff.value_for_charge(:agreed_availability_charge)).to eq('6.66')
        expect(energy_tariff.value_for_charge(:excess_availability_charge)).to eq('7.77')
        expect(energy_tariff.value_for_charge(:asc_limit_kw)).to eq('8.88')
        expect(energy_tariff.value_for_charge(:reactive_power_charge)).to eq('9.99')
        expect(energy_tariff.value_for_charge(:feed_in_tariff_levy)).to eq('9.87')
        expect(energy_tariff.value_for_charge(:settlement_agency_fee)).to eq('6.54')
        expect(energy_tariff.value_for_charge(:meter_asset_provider_charge)).to eq('3.21')
        expect(energy_tariff.value_for_charge(:nhh_metering_agent_charge)).to eq('1.9')
        expect(energy_tariff.value_for_charge(:nhh_automatic_meter_reading_charge)).to eq('0.12')
        expect(energy_tariff.value_for_charge(:data_collection_dcda_agent_charge)).to eq('0.34')
      end
    end
  end
end
