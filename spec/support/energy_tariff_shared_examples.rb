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
  it 'has buttons to create new tariffs' do
    expect(page).to have_link("Add gas tariff")
    expect(page).to have_link("Add electricity tariff")
  end

  context 'when there are existing tariffs' do
    include_context "with flat price electricity and gas tariffs"
    before { refresh }
    it 'displays the gas tariff' do
      within '#gas-tariffs-table' do
        expect(page).to have_content(gas_tariff.name)
        expect(page).to have_content(gas_tariff.start_date.to_s(:es_compact))
        expect(page).to have_content(gas_tariff.end_date.to_s(:es_compact))
        expect(page).to have_link("Full details")
        expect(page).to have_link("Edit")
        expect(page).to have_link("Delete")
      end
    end
    it 'displays the electricity tariff' do
      within '#electricity-tariffs-table' do
        expect(page).to have_content(electricity_tariff.name)
        expect(page).to have_content(electricity_tariff.start_date.to_s(:es_compact))
        expect(page).to have_content(electricity_tariff.end_date.to_s(:es_compact))
        expect(page).to have_link("Full details")
        expect(page).to have_link("Edit")
        expect(page).to have_link("Delete")
      end
    end
  end
end

RSpec.shared_examples "a gas tariff editor with no meter selection" do
  before { click_link('Add gas tariff') }
  it 'can create a flat rate tariff and add prices and charges' do
    expect(page).not_to have_content('Select meters for this tariff')
    expect(page).to have_content('Choose a name and date range')

    fill_in 'Name', with: 'My First Gas Tariff'
    click_button('Next')

    expect(page).to have_content('My First Gas Tariff')

    fill_in "energy_tariff_price[value]", with: '1.5'
    click_button('Next')

    expect(page).to have_content('Add standing charges')
    expect(page).to have_content('My First Gas Tariff')

    fill_in "energy_tariff_charges[fixed_charge][value]", with: '4.56'
    select 'month', from: 'energy_tariff_charges[fixed_charge][units]'
    check 'energy_tariff_charges[energy_tariff][ccl]'
    select '5', from: 'energy_tariff_charges[energy_tariff][vat_rate]'

    click_button('Next')

    expect(page).to have_content('Tariff details')
    expect(page).to have_content('5')
    expect(page).to have_content('Flat rate tariff')
    expect(page).to have_content('£1.50 per kWh')
    expect(page).to have_content('£4.56 per month')
    expect(page).not_to have_link('Delete')

    click_link('Finished')
    expect(page).to have_content('Manage and view tariffs')
    expect(page).to have_content('My First Gas Tariff')

    energy_tariff = EnergyTariff.last
    expect(energy_tariff.enabled).to be true
    expect(energy_tariff.meter_type.to_sym).to eq(:gas)
    expect(energy_tariff.tariff_holder_type).to eq(tariff_holder_type)
    expect(energy_tariff.tariff_holder).to eq(tariff_holder)
    expect(energy_tariff.created_by).to eq(current_user)
    expect(energy_tariff.updated_by).to eq(nil)

    expect(energy_tariff.meters).to match_array([])
    expect(energy_tariff.vat_rate).to eq(5)
    expect(energy_tariff.ccl).to be_truthy
    energy_tariff_price = energy_tariff.energy_tariff_prices.first
    expect(energy_tariff_price.start_time.to_s(:time)).to eq('00:00')
    expect(energy_tariff_price.end_time.to_s(:time)).to eq('23:30')
    expect(energy_tariff_price.units).to eq('kwh')
  end
end

RSpec.shared_examples "a gas tariff editor with meter selection" do
  let(:tariff_title)  { "My First Tariff for #{mpan_mprn}" }
  before { click_link('Add gas tariff') }
  it 'can create a tariff and associate the meters' do
    #Meter selection
    expect(page).to have_content('Select meters for this tariff')
    check('specific_meters')
    check(mpan_mprn)
    click_button('Next')

    #Name and dates
    expect(page).to have_content('Choose a name and date range')
    expect(page).to have_content(mpan_mprn)

    fill_in 'Name', with: tariff_title
    click_button('Next')

    energy_tariff = EnergyTariff.last
    expect(energy_tariff.enabled).to be true
    expect(energy_tariff.meter_type.to_sym).to eq(:gas)
    expect(energy_tariff.tariff_holder_type).to eq('School')
    expect(energy_tariff.tariff_holder).to eq(school)
    expect(energy_tariff.meters).to match_array([meter])
  end

  it 'doesnt require a meter to be selected by default' do
    expect(page).to have_content('Select meters for this tariff')
    expect(page).to have_unchecked_field('specific_meters')
    click_button('Next')
    expect(page).to have_content('Choose a name and date range')
  end

  it 'requires a meter to be selected if we check the box' do
    expect(page).to have_content('Select meters for this tariff')
    expect(page).to have_content("Will this tariff apply to all #{meter.fuel_type} meters at the school or just specific meters?")
    check('specific_meters')
    uncheck(meter.mpan_mprn.to_s)

    click_button('Next')
    expect(page).to have_content('Please select at least one meter for this tariff. Or uncheck option to apply tariff to all meters')
    expect(page).to have_content('Select meters for this tariff')
  end

end

RSpec.shared_examples "an electricity tariff editor with no meter selection" do
  before { click_link('Add electricity tariff') }

  it 'can handle a user quitting the forms early after filling required field' do
    expect(page).not_to have_content('Select meters for this tariff')
    expect(page).to have_content('Choose a name and date range')
    fill_in 'Name', with: 'My First Tariff'
    click_button('Next')
    click_button('Simple')

    visit tariff_index_path

    expect(page).to have_content('My First Tariff')
  end

  it 'can create a flat rate tariff with just a price' do
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
    expect(page).to have_content('Manage and view tariffs')

    energy_tariff = EnergyTariff.last
    expect(energy_tariff.enabled).to be true
    expect(energy_tariff.meter_type.to_sym).to eq(:electricity)
    expect(energy_tariff.tariff_holder_type).to eq(tariff_holder_type)
    expect(energy_tariff.tariff_holder).to eq(tariff_holder)
    expect(energy_tariff.created_by).to eq(current_user)
    expect(energy_tariff.updated_by).to eq(current_user)

    expect(energy_tariff.meters).to match_array([])
    expect(energy_tariff.tariff_type == 'flat_rate').to be_truthy
    expect(energy_tariff.vat_rate).to eq(nil)
    expect(energy_tariff.ccl).to be_falsey
    energy_tariff_price = energy_tariff.energy_tariff_prices.first
    expect(energy_tariff_price.start_time.to_s(:time)).to eq('00:00')
    expect(energy_tariff_price.end_time.to_s(:time)).to eq('23:30')
    expect(energy_tariff_price.value.to_s).to eq('1.5')
    expect(energy_tariff_price.units).to eq('kwh')
  end

  it 'can create a differential tariff and add prices and charges' do
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
    expect(page).to have_content('Manage and view tariffs')

    energy_tariff = EnergyTariff.last
    expect(energy_tariff.enabled).to be true
    expect(energy_tariff.meter_type.to_sym).to eq(:electricity)
    expect(energy_tariff.tariff_holder_type).to eq(tariff_holder_type)
    expect(energy_tariff.tariff_holder).to eq(tariff_holder)
    expect(energy_tariff.created_by).to eq(current_user)
    expect(energy_tariff.updated_by).to eq(current_user)
    expect(energy_tariff.meters).to match_array([])
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

  it 'can create a flat rate tariff and add all the charges' do
    fill_in 'Name', with: 'My First Tariff'
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
    select '20', from: 'energy_tariff_charges[energy_tariff][vat_rate]'

    click_button('Next')
    expect(page).to have_content('Tariff details')

    energy_tariff = EnergyTariff.last
    expect(energy_tariff.enabled).to be true
    expect(energy_tariff.meter_type.to_sym).to eq(:electricity)
    expect(energy_tariff.tariff_holder_type).to eq(tariff_holder_type)
    expect(energy_tariff.tariff_holder).to eq(tariff_holder)
    expect(energy_tariff.created_by).to eq(current_user)
    expect(energy_tariff.updated_by).to eq(current_user)
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

RSpec.shared_examples "an electricity tariff editor with meter selection" do
  let(:tariff_title)  { "My First Tariff for #{mpan_mprn}" }
  before              { click_link('Add electricity tariff') }

  it 'can create a flat rate tariff and associate the meters' do
    #Meter selection
    expect(page).to have_content('Select meters for this tariff')
    check('specific_meters')
    check(mpan_mprn)
    click_button('Next')

    #Name and dates
    expect(page).to have_content('Choose a name and date range')
    expect(page).to have_content(mpan_mprn)

    fill_in 'Name', with: tariff_title
    click_button('Next')

    energy_tariff = EnergyTariff.last
    expect(energy_tariff.enabled).to be true
    expect(energy_tariff.meter_type.to_sym).to eq(:electricity)
    expect(energy_tariff.tariff_holder_type).to eq('School')
    expect(energy_tariff.tariff_holder).to eq(school)
    expect(energy_tariff.meters).to match_array([meter])
  end

  it 'can create a differential tariff and associate the meters' do
    #Meter selection
    expect(page).to have_content('Select meters for this tariff')
    check('specific_meters')
    check(mpan_mprn)
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
    expect(page).to have_content('Manage and view tariffs')

    energy_tariff = EnergyTariff.last
    expect(energy_tariff.enabled).to be true
    expect(energy_tariff.meter_type.to_sym).to eq(:electricity)
    expect(energy_tariff.meters).to match_array([meter])
    expect(energy_tariff.tariff_holder_type).to eq(tariff_holder_type)
    expect(energy_tariff.tariff_holder).to eq(tariff_holder)
    expect(energy_tariff.created_by).to eq(current_user)
    expect(energy_tariff.updated_by).to eq(current_user)
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

  it 'doesnt require a meter to be selected by default' do
    expect(page).to have_content('Select meters for this tariff')
    expect(page).to have_unchecked_field('specific_meters')
    click_button('Next')
    expect(page).to have_content('Choose a name and date range')
  end

  it 'requires a meter to be selected if we check the box' do
    expect(page).to have_content('Select meters for this tariff')
    expect(page).to have_content("Will this tariff apply to all #{meter.fuel_type} meters at the school or just specific meters?")
    check('specific_meters')
    uncheck(meter.mpan_mprn.to_s)

    click_button('Next')
    expect(page).to have_content('Please select at least one meter for this tariff. Or uncheck option to apply tariff to all meters')
    expect(page).to have_content('Select meters for this tariff')
  end
end

RSpec.shared_examples "a school tariff editor" do

  before(:each) do
    sign_in(current_user)
    visit school_path(school)
    within '#manage_school_menu' do
      click_on 'Manage tariffs'
    end
  end

  context 'when viewing index' do
    let(:tariff_holder)   { school }
    before { visit school_energy_tariffs_path(school) }
    it_behaves_like "a tariff editor index"
  end

  it 'is navigable from the manage school menu' do
    expect(current_path).to eq("/schools/#{school.slug}/energy_tariffs")
    expect(page).to have_content(I18n.t('schools.user_tariffs.index.title'))
    expect(page).to have_link('cost analysis pages')
  end

  context 'when creating gas tariffs' do
    let(:meter)       { gas_meter }
    let(:mpan_mprn)   { gas_meter.mpan_mprn.to_s }
    it_behaves_like "a gas tariff editor with meter selection"
  end

  context 'when creating electricity tariffs' do
    let(:meter)       { electricity_meter }
    let(:mpan_mprn)   { electricity_meter.mpan_mprn.to_s }
    let(:tariff_holder)       { school }
    let(:tariff_holder_type)  { 'School' }

    it_behaves_like "an electricity tariff editor with meter selection"
  end

end

RSpec.shared_examples "a school group energy tariff editor" do
  before(:each) { sign_in(current_user) }

  context 'has navigation links', skip: "Group tariff editor is temporarily admin only.  This skip can be removed when the group sub nav template is updated" do
    it 'from school group page to energy tariffs index' do
      visit school_group_path(school_group)
      click_link('Manage Group')
      click_link('Manage tariffs')
      expect(current_path).to eq("/school_groups/#{school_group.slug}/energy_tariffs")
      expect(page).to have_content(I18n.t('schools.user_tariffs.index.title'))
    end
  end

  context 'when viewing index' do
    let(:tariff_holder)   { school_group }
    before { visit school_group_energy_tariffs_path(school_group) }
    it_behaves_like "a tariff editor index"
  end

  context 'when creating tariffs' do
    let(:tariff_index_path)   { school_group_energy_tariffs_path(school_group) }
    let(:tariff_holder)       { school_group }
    let(:tariff_holder_type)  { 'SchoolGroup' }

    before(:each) do
      visit tariff_index_path
    end

    it_behaves_like "a gas tariff editor with no meter selection"
    it_behaves_like "an electricity tariff editor with no meter selection"
  end
end

RSpec.shared_examples "the site settings energy tariff editor" do
  before(:each) do
    visit admin_path
    click_link('Energy Tariffs')
  end

  context 'when viewing index' do
    let(:tariff_holder)   { SiteSettings.current }
    before { visit admin_settings_energy_tariffs_path }
    it_behaves_like "a tariff editor index"
  end

  it 'has expected index' do
    expect(page).to have_content(I18n.t('schools.user_tariffs.index.title'))
    expect(page).not_to have_link('cost analysis pages')
  end

  context 'when creating tariffs' do
    let(:tariff_index_path)   { admin_settings_energy_tariffs_path }
    let(:tariff_holder)       { SiteSettings.current }
    let(:tariff_holder_type)  { 'SiteSettings' }

    it_behaves_like "a gas tariff editor with no meter selection"
    it_behaves_like "an electricity tariff editor with no meter selection"
  end
end
