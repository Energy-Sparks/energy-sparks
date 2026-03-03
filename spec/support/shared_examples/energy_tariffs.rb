RSpec.shared_examples 'the user does not have access to the tariff editor' do
  it 'redirects away from the editor' do
    visit path
    if current_user.nil?
      expect(page).to have_current_path('/users/sign_in', ignore_query: true)
    elsif current_user.school
      if current_user.student_user?
        expect(page).to have_current_path("/pupils/schools/#{current_user.school.slug}", ignore_query: true)
      else
        expect(page).to have_current_path("/schools/#{current_user.school.slug}", ignore_query: true)
      end
    elsif current_user.group_admin?
      expect(page).to have_current_path("/school_groups/#{current_user.school_group.slug}/map", ignore_query: true)
    else
      expect(page).to have_current_path('/schools', ignore_query: true)
    end
  end
end

RSpec.shared_examples 'a tariff editor index' do
  before { allow_any_instance_of(EnergyTariffsHelper).to receive(:any_smart_meters?).and_return(true) }

  it 'navigates the index tabs' do
    expect(current_path).to end_with('energy_tariffs')

    if tariff_holder.school?
      expect(page).not_to have_content('School tariffs')
      visit group_school_tariffs_school_energy_tariffs_path(tariff_holder)
      expect(page).to have_current_path("/schools/#{school.slug}/energy_tariffs", ignore_query: true)
    elsif tariff_holder.site_settings?
      expect(page).not_to have_content('School tariffs')
      visit group_school_tariffs_admin_settings_energy_tariffs_path(tariff_holder)
      expect(page).to have_current_path('/admin/settings/energy_tariffs', ignore_query: true)
    else
      click_link('School tariffs')
      expect(page).to have_current_path("/school_groups/#{school_group.slug}/energy_tariffs/group_school_tariffs", ignore_query: true)
    end

    if tariff_holder.school? || tariff_holder.school_group?
      expect(page).not_to have_content('System default tariffs')
      click_link('User supplied tariffs')
      expect(current_path).to end_with('energy_tariffs')
    else
      expect(page).not_to have_content('User supplied tariffs')
      click_link('System default tariffs')
      expect(current_path).to end_with('energy_tariffs')
    end

    if tariff_holder.school?
      click_link('Smart meter tariffs')
      expect(current_path).to end_with('energy_tariffs/smart_meter_tariffs')
    else
      expect(page).not_to have_content('Smart meter tariffs')
    end

    if tariff_holder.school? || tariff_holder.school_group?
      click_link('Default tariffs')
      expect(current_path).to end_with('energy_tariffs/default_tariffs')
    else
      expect(page).not_to have_content('Default tariffs')
    end
  end

  it 'has buttons to create new tariffs' do
    expect(page).to have_link('Add gas tariff')
    expect(page).to have_link('Add electricity tariff')
  end

  context 'when there are existing tariffs' do
    include_context 'with flat price electricity and gas tariffs'
    before { refresh }

    it 'displays the gas tariff' do
      within '#gas-tariffs-table' do
        expect(page).to have_content(gas_tariff.start_date.to_fs(:es_compact))
        expect(page).to have_content(gas_tariff.end_date.to_fs(:es_compact))
        expect(page).to have_link(gas_tariff.name)
        expect(page).to have_link('Edit')
        expect(page).to have_link('Delete') unless tariff_holder.site_settings?
      end
    end

    it 'displays the electricity tariff' do
      within '#electricity-tariffs-table' do
        expect(page).to have_content(electricity_tariff.start_date.to_fs(:es_compact))
        expect(page).to have_content(electricity_tariff.end_date.to_fs(:es_compact))
        expect(page).to have_link(electricity_tariff.name)
        expect(page).to have_link('Edit')
        expect(page).to have_link('Delete') unless tariff_holder.site_settings?
      end
    end
  end
end

RSpec.shared_examples 'the user can create a tariff' do
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
    # Not yet usable
    expect(page).to have_content(I18n.t('schools.user_tariffs.show.not_usable'))
    expect(page).not_to have_css('#tariff-meters') unless tariff_holder.school?

    if current_user.admin?
      expect(page).to have_content('Notes (admin only)')
    else
      expect(page).not_to have_content('Notes (admin only)')
    end

    # Add price
    find('#prices-section-edit').click

    fill_in 'energy_tariff_price[value]', with: '0.15'
    click_button('Continue')
    expect(page).to have_content('£0.15 per kWh')

    # Add charges
    find('#charges-section-edit').click

    fill_in 'energy_tariff_charges[standing_charge][value]', with: '1.11'
    select 'day', from: 'energy_tariff_charges[standing_charge][units]'
    click_button('Continue')

    expect(page).not_to have_content('Add standing charges for this tariff')
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
    expect(energy_tariff_price.start_time.to_fs(:time)).to eq('00:00')
    expect(energy_tariff_price.end_time.to_fs(:time)).to eq('23:30')
    expect(energy_tariff_price.value).to eq(0.15)
    expect(energy_tariff_price.units).to eq('kwh')

    expect(energy_tariff.value_for_charge(:standing_charge)).to eq('1.11')
  end
end

RSpec.shared_examples 'the user can edit the tariff' do
  it 'allows me to edit price' do
    find('#prices-section-edit').click
    expect(page).to have_field('energy_tariff_price[value]', with: '0.1')

    fill_in 'energy_tariff_price[value]', with: '0.15'
    click_button('Continue')
    expect(page).to have_content('£0.15 per kWh')
    expect(page).not_to have_content(I18n.t('schools.user_tariffs.show.not_usable'))
  end

  it 'allows me to edit the standing charge' do
    expect(page).to have_content('No standing charges have been added')
    find('#charges-section-edit').click

    expect(page).to have_content('Add standing charges for this tariff')
    fill_in 'energy_tariff_charges[standing_charge][value]', with: '1.11'
    select 'day', from: 'energy_tariff_charges[standing_charge][units]'
    click_button('Continue')

    expect(page).not_to have_content('No standing charges have been added')
    expect(page).to have_content('£1.11 per day')
  end

  it 'allows me to edit the tariff metadata' do
    find('#metadata-section-edit').click
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

RSpec.shared_examples 'the user can change the type of tariff' do
  it 'allows switching between tariff types, deleting any consumption charges asscoated with the previous tariff type' do
    # Switching tariff types should delete all energy tariff prices associated with the previous tariff type
    expect(energy_tariff.tariff_type).to eq('flat_rate')
    expect(energy_tariff.energy_tariff_prices.count).to eq(1)
    find('#tariff-type-section-edit').click
    expect(page).to have_content('Is this a flat rate tariff?')
    expect(page).to have_content('Or a rate which varies by time of day (e.g. Day/Night tariff, Economy7)')
    click_button('Differential tariff')
    expect(page).to have_content('Differential tariff')
    expect(energy_tariff.energy_tariff_prices.count).to eq(0)

    # Add some differential tariff consumption charges
    find('#prices-section-edit').click
    expect(energy_tariff.energy_tariff_prices.count).to eq(2)
    find("#energy-tariff-show-button-#{energy_tariff.energy_tariff_prices.first.id}").click
    fill_in 'Rate in £/kWh', with: '0.5'
    click_button('Save')
    find("#energy-tariff-show-button-#{energy_tariff.energy_tariff_prices.last.id}").click
    fill_in 'Rate in £/kWh', with: '0.25'
    click_button('Save')
    click_link(energy_tariff.name)
    expect(page).to have_content('Differential tariff')
    expect(page).to have_content('£0.50 per kWh')
    expect(page).to have_content('£0.25 per kWh')

    # Selecting the existing tariff type should retain all energy tariff prices
    find('#tariff-type-section-edit').click
    expect(energy_tariff.reload.energy_tariff_prices.count).to eq(2)
    click_button('Differential tariff')
    expect(energy_tariff.reload.energy_tariff_prices.count).to eq(2)
    expect(page).to have_content('Differential tariff')
    expect(page).to have_content('£0.50 per kWh')
    expect(page).to have_content('£0.25 per kWh')

    # Switching tariff types should delete all energy tariff prices associated with the previous tariff type
    find('#tariff-type-section-edit').click
    click_button('Flat rate tariff')
    expect(page).to have_content('Flat rate tariff')
    expect(energy_tariff.reload.energy_tariff_prices.count).to eq(0)

    # Add some flat rate consumption charges
    find('#prices-section-edit').click
    fill_in 'energy_tariff_price[value]', with: '0.15'
    click_button('Continue')
    expect(energy_tariff.reload.energy_tariff_prices.count).to eq(1)
    expect(page).to have_content('£0.15 per kWh')

    # Selecting the existing tariff type should retain all energy tariff prices
    find('#tariff-type-section-edit').click
    click_button('Flat rate tariff')
    expect(page).to have_content('Flat rate tariff')
    expect(energy_tariff.reload.energy_tariff_prices.count).to eq(1)
    expect(page).to have_content('£0.15 per kWh')
  end
end

RSpec.shared_examples 'the user can not select the meter system' do
  it 'can not select which meter system types a tariff applies to' do
    expect(page).to have_content("All #{energy_tariff.meter_type} meters")
    expect(energy_tariff.applies_to).to eq('both')

    find('#meters-section-edit').click

    expect(page).to have_content('Select meters for this tariff')
    check('all_meters')
    expect(page).not_to have_content('both half-hourly and non half-hourly meters')
    expect(page).not_to have_content('half-hourly meters only')
    expect(page).not_to have_content('non half-hourly meters only')

    click_button('Continue')

    energy_tariff.reload
    expect(energy_tariff.meters).to match_array([])
    expect(energy_tariff.applies_to).to eq('both')
  end
end

RSpec.shared_examples 'the user can select the meter system' do
  it 'can select which meter system types a tariff applies to' do
    expect(page).to have_content('All electricity meters')
    expect(energy_tariff.applies_to).to eq('both')

    find('#meters-section-edit').click

    expect(page).to have_content('Select meters for this tariff')
    check('all_meters')
    expect(page).to have_content('both half-hourly and non half-hourly meters')
    expect(page).to have_content('half-hourly meters only')
    expect(page).to have_content('non half-hourly meters only')

    choose('energy_tariff[applies_to]', option: 'half_hourly')

    click_button('Continue')

    energy_tariff.reload
    expect(energy_tariff.meters).to match_array([])
    expect(energy_tariff.applies_to).to eq('half_hourly')
  end
end

RSpec.shared_examples 'the user can not see the meterless applies to editor' do
  it 'can select which meter system types a tariff applies to' do
    expect(page).to have_content("All #{energy_tariff.meter_type} meters")
    expect(page).not_to have_content('Tariff applies to')
  end
end

RSpec.shared_examples 'the meterless applies to editor' do
  let!(:electricity_tariff) { create(:energy_tariff, :with_flat_price, start_date: Date.new(2022, 1, 1), end_date: Date.new(2022, 12, 31), tariff_holder: tariff_holder, meter_type: :electricity)}
  let!(:gas_tariff)         { create(:energy_tariff, :with_flat_price, start_date: Date.new(2022, 1, 1), end_date: Date.new(2022, 12, 31), tariff_holder: tariff_holder, meter_type: :gas)}

  it 'can select which meter system types an electricity tariff applies to' do
    # assumes starting from tariff index
    refresh
    click_on electricity_tariff.name
    expect(electricity_tariff.meters).to match_array([])
    expect(electricity_tariff.applies_to).to eq('both')
    expect(page).to have_content('Tariff applies to')
    find('#applies-to-section-edit').click
    expect(page).to have_content('Choose which meter systems this tariff applies to')
    expect(page).to have_content('both half-hourly and non half-hourly meters')
    expect(page).to have_content('half-hourly meters only')
    expect(page).to have_content('non half-hourly meters only')
    choose('energy_tariff[applies_to]', option: 'half_hourly')
    click_button('Continue')
    electricity_tariff.reload
    expect(electricity_tariff.meters).to match_array([])
    expect(electricity_tariff.applies_to).to eq('half_hourly')
  end

  it 'can not select which meter system types a gas tariff applies to' do
    # assumes starting from tariff index
    refresh
    click_on gas_tariff.name
    expect(gas_tariff.meters).to match_array([])
    expect(gas_tariff.applies_to).to eq('both')
    expect(page).not_to have_content('Tariff applies to')
  end
end

RSpec.shared_examples 'the user can select the meters' do
  it 'can create a tariff and associate the meters' do
    expect(page).to have_content("All #{energy_tariff.meter_type} meters")

    find('#meters-section-edit').click
    # Meter selection
    expect(page).to have_content('Select meters for this tariff')
    uncheck('all_meters')
    check(mpan_mprn)
    click_button('Continue')

    expect(page).not_to have_content('All electricity meters')
    expect(page).to have_content(meter.name_or_mpan_mprn)
    energy_tariff.reload
    expect(energy_tariff.meters).to match_array([meter])
  end

  it 'doesnt require a meter to be selected by default' do
    expect(page).to have_content("All #{energy_tariff.meter_type} meters")
    find('#meters-section-edit').click

    expect(page).to have_content('Select meters for this tariff')
    expect(page).to have_checked_field('all_meters')
    click_button('Continue')
    expect(page).to have_content("All #{energy_tariff.meter_type} meters")
  end

  it 'requires a meter to be selected if we check the box' do
    expect(page).to have_content("All #{energy_tariff.meter_type} meters")
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
