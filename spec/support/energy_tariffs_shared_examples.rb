RSpec.shared_examples "the user does not have access to the tariff editor" do
  it 'redirects away from the editor' do
    visit path
    if current_user.nil?
      expect(current_path).to eq('/users/sign_in')
    elsif current_user.school
      if current_user.pupil?
        expect(current_path).to eq("/pupils/schools/#{current_user.school.slug}")
      else
        expect(current_path).to eq("/schools/#{current_user.school.slug}")
      end
    elsif current_user.group_admin?
      expect(current_path).to eq("/school_groups/#{current_user.school_group.slug}")
    else
      expect(current_path).to eq('/schools')
    end
  end
end

RSpec.shared_examples "a tariff editor index" do
  before { allow_any_instance_of( EnergyTariffsHelper ).to receive(:any_smart_meters?).and_return(true) }

  it 'navigates the index tabs' do
    expect(current_path).to end_with('energy_tariffs')
    click_link('User supplied tariffs')
    expect(current_path).to end_with('energy_tariffs')
    if tariff_holder.school?
      click_link('Smart meter tariffs')
      expect(current_path).to end_with('energy_tariffs/smart_meter_tariffs')
    end
    click_link('Default tariffs')
    expect(current_path).to end_with('energy_tariffs/default_tariffs')
  end

  it 'has buttons to create new tariffs' do
    expect(page).to have_link("Add gas tariff")
    expect(page).to have_link("Add electricity tariff")
  end

  context 'when there are existing tariffs' do
    include_context "with flat price electricity and gas tariffs"
    before { refresh }
    it 'displays the gas tariff' do
      within '#gas-tariffs-table' do
        expect(page).to have_content(gas_tariff.start_date.to_s(:es_compact))
        expect(page).to have_content(gas_tariff.end_date.to_s(:es_compact))
        expect(page).to have_link(gas_tariff.name)
        expect(page).to have_link("Edit")
        expect(page).to have_link("Delete") if !tariff_holder.site_settings?
      end
    end
    it 'displays the electricity tariff' do
      within '#electricity-tariffs-table' do
        expect(page).to have_content(electricity_tariff.start_date.to_s(:es_compact))
        expect(page).to have_content(electricity_tariff.end_date.to_s(:es_compact))
        expect(page).to have_link(electricity_tariff.name)
        expect(page).to have_link("Edit")
        expect(page).to have_link("Delete") if !tariff_holder.site_settings?
      end
    end
  end
end

RSpec.shared_examples "the user can create a tariff" do
  it 'can create a new tariff' do
    expect(page).to have_content('Choose a name and date range')
    fill_in 'Name', with: 'My First Tariff'
    fill_in 'Start date', with: '15/08/2023'
    fill_in 'End date', with: '16/08/2023'
    click_button('Continue')

    expect(page).to have_content('My First Tariff')
    expect(page).to have_content('Dates')
    expect(page).to have_content('Start date')
    expect(page).to have_content('15/08/2023')
    expect(page).to have_content('End date')
    expect(page).to have_content('16/08/2023')
    expect(page).to have_content('Flat rate tariff')
    #Not yet usable
    expect(page).to have_content(I18n.t('schools.user_tariffs.show.not_usable'))
    expect(page).to_not have_css('#tariff-meters') unless tariff_holder.school?

    if current_user.admin?
      expect(page).to have_content('Notes (admin only)')
    else
      expect(page).not_to have_content('Notes (admin only)')
    end

    #Add price
    find("#prices-section-edit").click

    fill_in "energy_tariff_price[value]", with: '1.5'
    click_button('Continue')
    expect(page).to have_content('£1.50 per kWh')

    #Add charges
    find("#charges-section-edit").click

    fill_in "energy_tariff_charges[standing_charge][value]", with: '1.11'
    select 'day', from: 'energy_tariff_charges[standing_charge][units]'
    click_button('Continue')

    expect(page).to_not have_content("Add standing charges for this tariff")
    expect(page).to have_content('£1.11 per day')

    click_on('Finished')

    energy_tariff = EnergyTariff.last
    expect(energy_tariff.enabled).to be true
    expect(energy_tariff.meter_type.to_sym).to eq(meter_type)
    expect(energy_tariff.tariff_holder_type).to eq(tariff_holder_type)
    expect(energy_tariff.tariff_holder).to eq(tariff_holder)
    expect(energy_tariff.created_by).to eq(current_user)
    expect(energy_tariff.meters).to match_array([])

    energy_tariff_price = energy_tariff.energy_tariff_prices.first
    expect(energy_tariff_price.start_time.to_s(:time)).to eq('00:00')
    expect(energy_tariff_price.end_time.to_s(:time)).to eq('23:30')
    expect(energy_tariff_price.value).to eq(1.5)
    expect(energy_tariff_price.units).to eq('kwh')

    expect(energy_tariff.value_for_charge(:standing_charge)).to eq('1.11')
  end
end

RSpec.shared_examples "the user can edit the tariff" do
  it 'allows me to edit price' do
    find("#prices-section-edit").click
    expect(page).to have_field('energy_tariff_price[value]', with: '1.0')

    fill_in "energy_tariff_price[value]", with: '1.5'
    click_button('Continue')
    expect(page).to have_content('£1.50 per kWh')
    expect(page).to_not have_content(I18n.t('schools.user_tariffs.show.not_usable'))
  end

  it 'allows me to edit the standing charge' do
    expect(page).to have_content("No standing charges have been added")
    find("#charges-section-edit").click

    expect(page).to have_content("Add standing charges for this tariff")
    fill_in "energy_tariff_charges[standing_charge][value]", with: '1.11'
    select 'day', from: 'energy_tariff_charges[standing_charge][units]'
    click_button('Continue')

    expect(page).to_not have_content("No standing charges have been added")
    expect(page).to have_content('£1.11 per day')
  end

  it 'allows me to edit the tariff metadata' do
    find("#metadata-section-edit").click
    expect(page).to have_content('Name')
    expect(page).to have_content('Start date')
    expect(page).to have_content('End date')

    fill_in 'Name', with: 'My Updated Tariff'
    fill_in 'Start date', with: '13/08/2023'
    fill_in 'End date', with: '14/08/2023'
    click_button('Continue')

    expect(page).to have_content('My Updated Tariff')
    expect(page).to have_content('Dates')
    expect(page).to have_content('Start date')
    expect(page).to have_content('13/08/2023')
    expect(page).to have_content('End date')
    expect(page).to have_content('14/08/2023')
  end
end

RSpec.shared_examples "the user can change the type of tariff" do
  it 'allows switching to flat rate' do
    expect(page).to have_content('Flat rate tariff')
    find('#tariff-type-section-edit').click()
    click_button('Flat rate tariff')
    expect(page).to have_content('Flat rate tariff')
    energy_tariff.reload
    expect(energy_tariff.energy_tariff_prices.any?).to be false
  end

  it 'allows switching to differential' do
    expect(page).to have_content('Flat rate tariff')
    find('#tariff-type-section-edit').click()
    click_button('Differential tariff')
    expect(page).to have_content('Differential tariff')
    energy_tariff.reload
    expect(energy_tariff.energy_tariff_prices.any?).to be false
    find('#tariff-type-section-edit').click()
    click_button('Flat rate tariff')
    expect(page).to have_content('Flat rate tariff')
  end
end

RSpec.shared_examples "the user can select the meters" do
  it 'can create a tariff and associate the meters' do
    expect(page).to have_content("All electricity meters")

    find('#meters-section-edit').click
    #Meter selection
    expect(page).to have_content('Select meters for this tariff')
    uncheck('all_meters')
    check(mpan_mprn)
    click_button('Continue')

    expect(page).to_not have_content("All electricity meters")
    expect(page).to have_content(meter.name_or_mpan_mprn)
    energy_tariff.reload
    expect(energy_tariff.meters).to match_array([meter])
  end

  it 'doesnt require a meter to be selected by default' do
    expect(page).to have_content("All electricity meters")
    find('#meters-section-edit').click

    expect(page).to have_content('Select meters for this tariff')
    expect(page).to have_checked_field('all_meters')
    click_button('Continue')
    expect(page).to have_content("All electricity meters")
  end

  it 'requires a meter to be selected if we check the box' do
    expect(page).to have_content("All electricity meters")
    find('#meters-section-edit').click

    expect(page).to have_content('Select meters for this tariff')
    expect(page).to have_content("Will this tariff apply to all #{meter.fuel_type} meters at the school or just specific meters?")
    uncheck('all_meters')
    uncheck(meter.mpan_mprn.to_s)

    click_button('Continue')
    expect(page).to have_content('Please select at least one meter for this tariff. Or uncheck option to apply tariff to all meters')
    expect(page).to have_content('Select meters for this tariff')
  end

end
