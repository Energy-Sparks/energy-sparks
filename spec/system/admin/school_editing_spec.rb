require 'rails_helper'

RSpec.describe 'editing school details', type: :system do
  let!(:admin)              { create(:admin)}

  let!(:ks1)                { KeyStage.create(name: 'KS1') }
  let!(:ks2)                { KeyStage.create(name: 'KS2') }
  let!(:ks3)                { KeyStage.create(name: 'KS3') }

  let(:school_name)         { 'Oldfield Park Infants' }
  let!(:school)             { create(:school, name: school_name, latitude: 51.34062, longitude: -2.30142)}

  before do
    sign_in(admin)
    visit school_path(school)
  end

  it 'I can set up a school for KS1' do
    click_on('Edit school details')
    expect(school.key_stages).not_to include(ks1)
    expect(school.key_stages).not_to include(ks2)
    expect(school.key_stages).not_to include(ks3)

    check('KS1')
    click_on('Update School')
    school.reload
    expect(school.key_stages).to include(ks1)
    expect(school.key_stages).not_to include(ks2)
    expect(school.key_stages).not_to include(ks3)
  end

  it 'I can set up a school for KS1 and KS2' do
    click_on('Edit school details')
    expect(school.key_stages).not_to include(ks1)
    expect(school.key_stages).not_to include(ks2)
    expect(school.key_stages).not_to include(ks3)

    check('KS1')
    check('KS2')
    click_on('Update School')
    school.reload
    expect(school.key_stages).to include(ks1)
    expect(school.key_stages).to include(ks2)
    expect(school.key_stages).not_to include(ks3)
  end

  it 'can set climate impact reporting preference' do
    click_on('Edit school details')

    choose('Prefer the display of chart data in kg CO2, where available')
    click_on('Update School')
    school.reload

    expect(school.chart_preference).to eq 'carbon'
  end

  it 'can see when the school was created on Energy Sparks' do
    click_on('Edit school details')
    date = school.created_at
    expect(page).to have_content "#{school.name} was created on #{date.strftime('%a')} #{date.day.ordinalize} #{date.strftime('%b %Y')}"
  end

  it 'can edit lat/lng' do
    click_on('Edit school details')

    fill_in 'Latitude', with: '52.123'
    fill_in 'Longitude', with: '-1.123'
    click_on('Update School')

    school.reload
    expect(school.latitude.to_s).to eq('52.123')
    expect(school.longitude.to_s).to eq('-1.123')
  end

  it 'can create an active date' do
    click_on('Edit school details')

    expect(school.observations).to be_empty

    expect(page).to have_field('Activation date')
    activation_date = Date.parse('01/01/2020')

    fill_in 'Activation date', with: activation_date.strftime('%d/%m/%Y')
    click_on('Update School')

    school.reload
    expect(school.activation_date).to eq activation_date

    click_on('Edit school details')
    fill_in 'Activation date', with: ''
    click_on('Update School')

    school.reload
    expect(school.activation_date).to eq nil
  end

  it 'can change target feature flag' do
    expect(school.enable_targets_feature?).to be true
    click_on('Edit school details')
    uncheck 'Enable targets feature'
    click_on('Update School')
    school.reload
    expect(school.enable_targets_feature?).to be false
  end

  context 'when updating school features checkboxes - excluding dinners js fields' do
    before do
      click_on('Edit school details')
      check 'Our school has solar PV panels'
      check 'Our school has night storage heaters'
      check 'Our school has its own swimming pool'
      check 'Our school uses oil for heating'
      check 'Our school is using LPG for heating'
      check 'Our school has a biomass boiler'
      check 'Our school has district heating'
      check 'Our school has a ground source heat pump'
      check 'Our school has an air source heat pump'
      check 'Our school has a water source heat pump'
      click_on('Update School')
      school.reload
    end

    it 'and changes are saved' do
      expect(school.indicated_has_solar_panels).to be true
      expect(school.indicated_has_storage_heaters).to be true
      expect(school.has_swimming_pool).to be true
      expect(school.heating_oil).to be true
      expect(school.heating_lpg).to be true
      expect(school.heating_biomass).to be true
      expect(school.heating_ground_source_heat_pump).to be true
      expect(school.heating_air_source_heat_pump).to be true
      expect(school.heating_water_source_heat_pump).to be true
    end
  end

  it 'can change climate reporting preference' do
    school.update!(chart_preference: :usage)
    refresh
    click_on('Edit school details')
    choose('Prefer the display of chart data in £, where available')
    click_on('Update School')

    school.reload
    expect(school.chart_preference).to eq 'cost'
  end
end
