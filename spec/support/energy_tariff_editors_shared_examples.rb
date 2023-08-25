RSpec.shared_examples "a basic gas tariff editor" do
  let(:meter_type) { :gas }
  context 'when adding a new tariff' do
    before { click_link('Add gas tariff') }
    include_examples 'the user can create a tariff'
  end

  context 'with an existing tariff' do
    let!(:energy_tariff)         { create(:energy_tariff, :with_flat_price, start_date: Date.new(2022,1,1), end_date: Date.new(2022,12,31), tariff_holder: tariff_holder, meter_type: meter_type)}
    before do
      #assumes staring from tariff index
      refresh
      click_on energy_tariff.name
    end

    include_examples "the user can edit the tariff"

    it 'does not offer option to edit the type of tariff' do
      expect(page).to_not have_css('#choose-type')
    end
  end
end

RSpec.shared_examples "a basic electricity tariff editor" do
  let(:meter_type) { :electricity }
  context 'when adding a new tariff' do
    before { click_link('Add electricity tariff') }
    include_examples 'the user can create a tariff'
  end

  context 'with an existing tariff' do
    let!(:energy_tariff)         { create(:energy_tariff, :with_flat_price, start_date: Date.new(2022,1,1), end_date: Date.new(2022,12,31), tariff_holder: tariff_holder, meter_type: meter_type)}
    before do
      #assumes staring from tariff index
      refresh
      click_on energy_tariff.name
    end

    include_examples "the user can edit the tariff"
    include_examples 'the user can change the type of tariff'

    it 'allows adding all the charges' do
      find('#charges-section-edit').click

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

      click_button('Continue')

      energy_tariff = EnergyTariff.last

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

  context 'with an existing differential tariff' do
    let!(:energy_tariff)         { create(:energy_tariff, tariff_type: :differential, tariff_holder: tariff_holder, meter_type: meter_type)}

    before do
      #assumes staring from tariff index
      refresh
      click_on energy_tariff.name
    end

    it 'can create a differential tariff and add, edit, delete, and reset prices and charges' do
      find('#prices-section-edit').click()
      expect(page).to have_content('Rate from 00:00 to 07:00')
      expect(page).to have_content('Rate from 07:00 to 00:00')
      expect(page).to have_link('Add rate')
      expect(page).to have_content('Please add valid prices for all marked rates')

      page.all('.energy-tariff-show-button')[0].click

      select '00', from: 'energy_tariff_price_start_time_4i'
      select '30', from: 'energy_tariff_price_start_time_5i'
      select '06', from: 'energy_tariff_price_end_time_4i'
      select '30', from: 'energy_tariff_price_end_time_5i'

      fill_in 'Rate in £/kWh', with: '1.5'
      click_button('Save')

      expect(page).to have_content('Rate from 00:30 to 06:30')
      expect(page).to have_content('Rate from 07:00 to 00:00')
      expect(page).to have_content('£1.50 per kWh')
      expect(page).to have_content('£ per kWh')

      expect(page).to have_content('Please add valid prices for all marked rates.')
      first('.energy-tariff-show-button').click

      fill_in 'Rate in £/kWh', with: '1.5'
      click_button('Save')

      expect(page).to have_content('Please add valid prices for all marked rates.')
      first('.energy-tariff-show-button').click

      select '00', from: 'energy_tariff_price_start_time_4i'
      select '00', from: 'energy_tariff_price_start_time_5i'
      select '07', from: 'energy_tariff_price_end_time_4i'
      select '00', from: 'energy_tariff_price_end_time_5i'
      click_button('Save')

      expect(page).to have_content('Please add valid prices for all marked rates.')
      expect(page).not_to have_content('Incomplete 24 hour coverage. Please add another rate.')
      expect(page).not_to have_content('A differential tariff must have at least 2 prices, e.g. a day time and a night-time rate. Please add prices, or reset to default.')
      expect(find("a", text: "Add rate")[:class]).to eq('btn disabled')
      expect(find("a", text: "Reset to default")[:class]).to eq('btn disabled')

      click_link("Delete", match: :first)

      expect(page).not_to have_content('Rate from 00:30 to 06:30')
      expect(page).to have_content('Rate from 07:00 to 00:00')
      expect(page).not_to have_content('£1.50 per kWh')
      expect(page).to have_content('£ per kWh')

      expect(page).not_to have_content('Complete 24 hour coverage.')
      expect(page).to have_content('Please add valid prices for all marked rates.')
      expect(page).not_to have_content('A differential tariff must have at least 2 prices, e.g. a day time and a night-time rate. Please add prices, or reset to default.')
      expect(find("a", text: "Add rate")[:class]).to eq('btn')
      expect(find("a", text: "Reset to default")[:class]).to eq('btn')

      click_link("Delete", match: :first)

      expect(page).not_to have_content('Rate from 00:30 to 06:30')
      expect(page).not_to have_content('Rate from 07:00 to 00:00')
      expect(page).not_to have_content('£1.50 per kWh')
      expect(page).not_to have_content('£ per kWh')

      expect(page).not_to have_content('Please add valid prices for all marked rates.')
      expect(page).not_to have_content('Incomplete 24 hour coverage. Please add another rate.')
      expect(page).to have_content('A differential tariff must have at least 2 prices, e.g. a day time and a night-time rate. Please add prices, or reset to default.')
      expect(find("a", text: "Add rate")[:class]).to eq('btn')
      expect(find("a", text: "Reset to default")[:class]).to eq('btn')

      click_link('Reset to default')

      expect(page).to have_content('Rate from 00:00 to 07:00')
      expect(page).to have_content('Rate from 07:00 to 00:00')
      expect(page).to have_content('£ per kWh')
      expect(page).to have_content('£ per kWh')

      find("#energy-tariff-show-button-#{energy_tariff.energy_tariff_prices.first.id}").click

      fill_in 'Rate in £/kWh', with: '1.5'
      click_button('Save')

      expect(page).to have_content('Rate from 00:00 to 07:00')
      expect(page).to have_content('Rate from 07:00 to 00:00')
      expect(page).to have_content('£1.50 per kWh')
      expect(page).to have_content('£ per kWh')

      expect(find("a", text: "Continue")[:class]).to eq('btn disabled')

      find("#energy-tariff-show-button-#{energy_tariff.energy_tariff_prices.last.id}").click

      fill_in 'Rate in £/kWh', with: '2.5'
      click_button('Save')

      expect(page).to have_content('Rate from 00:00 to 07:00 ')
      expect(page).to have_content('Rate from 07:00 to 00:00')
      expect(page).to have_content('£1.50 per kWh')
      expect(page).to have_content('£2.50 per kWh')

      expect(page).to have_content('Complete 24 hour coverage.')
      expect(page).not_to have_content('Incomplete 24 hour coverage. Please add another rate.')
      expect(page).not_to have_content('A differential tariff must have at least 2 prices, e.g. a day time and a night-time rate. Please add prices, or reset to default.')
      expect(find("a", text: "Add rate")[:class]).to eq('btn disabled')
      expect(find("a", text: "Reset to default")[:class]).to eq('btn disabled')

      click_link('Continue')

      expect(page).to_not have_content(I18n.t('schools.user_tariffs.show.not_usable'))

      energy_tariff_price = energy_tariff.energy_tariff_prices.first
      expect(energy_tariff_price.start_time.to_s(:time)).to eq('00:00')
      expect(energy_tariff_price.end_time.to_s(:time)).to eq('07:00')
      expect(energy_tariff_price.value.to_s).to eq('1.5')
      expect(energy_tariff_price.units).to eq('kwh')
      energy_tariff_price = energy_tariff.energy_tariff_prices.last
      expect(energy_tariff_price.start_time.to_s(:time)).to eq('07:00')
      expect(energy_tariff_price.end_time.to_s(:time)).to eq('00:00')
      expect(energy_tariff_price.value.to_s).to eq('2.5')
      expect(energy_tariff_price.units).to eq('kwh')
    end
  end
end

RSpec.shared_examples "a school tariff editor" do
  let(:tariff_holder)       { school }
  let(:tariff_holder_type)  { 'School' }

  before(:each) do
    sign_in(current_user)
    visit school_path(school)
    within '#manage_school_menu' do
      click_on 'Manage tariffs'
    end
  end

  context 'when viewing index' do
    let(:tariff_holder) { school }
    before { visit school_energy_tariffs_path(school) }
    it_behaves_like "a tariff editor index"
  end

  it 'is navigable from the manage school menu' do
    expect(current_path).to eq("/schools/#{school.slug}/energy_tariffs")
    expect(page).to have_content(I18n.t('schools.user_tariffs.index.title'))
    expect(page).to have_link('cost analysis pages')
  end

  context 'when creating tariffs' do
    context 'for electricity meters' do
      include_examples 'a basic electricity tariff editor'
    end
    context 'for gas meters' do
      include_examples 'a basic gas tariff editor'
    end
  end

  context 'when editing a school tariff' do
    let(:meter)           { electricity_meter }
    let(:mpan_mprn)       { electricity_meter.mpan_mprn.to_s }
    let(:meter_type)      { :electricity }
    let!(:energy_tariff)  { create(:energy_tariff, :with_flat_price, start_date: Date.new(2022,1,1), end_date: Date.new(2022,12,31), tariff_holder: tariff_holder, meter_type: meter_type)}
    before(:each) do
      refresh
      click_on(energy_tariff.name)
    end
    include_examples "the user can select the meters"
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
    let(:tariff_holder) { school_group }
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

    it_behaves_like 'a basic gas tariff editor'
    it_behaves_like 'a basic electricity tariff editor'
  end
end

RSpec.shared_examples "the site settings energy tariff editor" do
  before(:each) do
    visit admin_path
    click_link('Energy Tariffs')
  end

  context 'when viewing index' do
    let(:tariff_holder) { SiteSettings.current }
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

    it_behaves_like 'a basic gas tariff editor'
    it_behaves_like 'a basic electricity tariff editor'
  end
end
