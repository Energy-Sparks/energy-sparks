require 'rails_helper'

RSpec.describe "school", type: :system do

  let(:school_name) { 'Oldfield Park Infants'}
  let!(:school)     { create(:school, name: school_name)}
  let!(:admin)      { create(:admin)}
  let!(:ks1)        { KeyStage.create(name: 'KS1') }
  let!(:ks2)        { KeyStage.create(name: 'KS2') }
  let!(:ks3)        { KeyStage.create(name: 'KS3') }

  it 'shows me a school page' do
    visit root_path
    click_on('Schools')
    expect(page.has_content? "Energy Sparks schools across the UK").to be true
    click_on(school_name)
    expect(page.has_link? "Pupil dashboard").to be true
    expect(page.has_content? school_name).to be true
    expect(page.has_no_content? "Gas").to be true
  end

  it 'links to the pupil dashboard' do
    visit school_path(school)

    within('.sub-navbar') do
      click_on('Pupil dashboard')
    end

    expect(page.has_title? 'Pupil dashboard').to be true
    expect(page.has_link? "Adult dashboard").to be true
    expect(page.has_content? school_name).to be true
  end

  describe 'when logged in' do
    before(:each) do
      sign_in(admin)
      visit root_path
      expect(page.has_content? 'Sign Out').to be true
      click_on('Schools')
      expect(page.has_content? "Energy Sparks schools across the UK").to be true
    end

    describe 'school with gas meter' do
      it 'shows me a school page' do
        school.configuration.update(gas_dashboard_chart_type: Schools::Configuration::TEACHERS_GAS_SIMPLE)
        click_on(school_name)
        expect(page.has_content? "Gas").to be true
        expect(page.has_content? "Electricity").to be false
      end
    end

    describe 'school with electricity meter' do
      it 'shows me a school page' do
        school.configuration.update(electricity_dashboard_chart_type: Schools::Configuration::TEACHERS_ELECTRICITY, fuel_configuration: Schools::FuelConfiguration.new(has_electricity: true, has_gas: false))
        click_on(school_name)
        expect(page.has_content? "Gas").to be false
        expect(page.has_content? "Electricity").to be true
      end
    end

    describe 'school with both meters' do
      it 'shows me a school page with both meters' do
        school.configuration.update(gas_dashboard_chart_type: Schools::Configuration::TEACHERS_GAS_SIMPLE, electricity_dashboard_chart_type: Schools::Configuration::TEACHERS_ELECTRICITY, fuel_configuration: Schools::FuelConfiguration.new(has_electricity: true, has_gas: true))
        click_on(school_name)
        expect(page.has_content? school_name).to be true
        expect(page.has_content? "Gas").to be true
        expect(page.has_content? "Electricity").to be true
      end
    end

    describe 'school management' do

      it 'I can set up a school for KS1' do
        click_on(school_name)
        click_on('Edit school details')
        expect(school.key_stages).to_not include(ks1)
        expect(school.key_stages).to_not include(ks2)
        expect(school.key_stages).to_not include(ks3)

        check('KS1')
        click_on('Update School')
        school.reload
        expect(school.key_stages).to include(ks1)
        expect(school.key_stages).to_not include(ks2)
        expect(school.key_stages).to_not include(ks3)
      end

      it 'I can set up a school for KS1 and KS2' do
        click_on(school_name)
        click_on('Edit school details')
        expect(school.key_stages).to_not include(ks1)
        expect(school.key_stages).to_not include(ks2)
        expect(school.key_stages).to_not include(ks3)

        check('KS1')
        check('KS2')
        click_on('Update School')
        school.reload
        expect(school.key_stages).to include(ks1)
        expect(school.key_stages).to include(ks2)
        expect(school.key_stages).to_not include(ks3)
      end

      it 'allows visibility management from school page' do
        click_on(school_name)
        click_on('Visible')
        school.reload
        expect(school).to_not be_visible
        click_on('Not visible')
        school.reload
        expect(school).to be_visible
      end

      it 'allows data process management' do
        create(:gas_meter, :with_unvalidated_readings, school: school)
        school.update(process_data: false)
        click_on(school_name)
        click_on('Not processing data')
        expect(page).to have_content "#{school.name} will now process data"
        school.reload
        expect(school.process_data).to eq(true)
        click_on('Processing data')
        school.reload
        expect(school.process_data).to eq(false)
      end

      it 'disallows data process management if the school has no meter readings' do
        school.update(process_data: false)
        click_on(school_name)
        click_on('Not processing data')
        expect(page).to have_content "#{school.name} cannot process data as it has no meter readings"
        school.reload
        expect(school.process_data).to eq(false)
      end

      it 'can see when the school was created on Energy Sparks' do
        click_on(school_name)
        click_on('Edit school details')
        date = school.created_at
        expect(page).to have_content "#{school.name} was created on #{date.strftime('%a')} #{date.day.ordinalize} #{date.strftime('%b %Y')}"
      end

      it 'can edit lat/lng' do
        click_on(school_name)
        click_on('Edit school details')

        fill_in 'Latitude', with: '52.123'
        fill_in 'Longitude', with: '-1.123'
        click_on('Update School')

        school.reload
        expect(school.latitude.to_s).to eq('52.123')
        expect(school.longitude.to_s).to eq('-1.123')
      end

      it 'can create an active date' do
        click_on(school_name)
        click_on('Edit school details')

        expect(school.observations).to be_empty

        expect(page).to have_field('Activation date')
        activation_date = Date.parse('01/01/2020')

        fill_in 'Activation date', with: activation_date.strftime("%d/%m/%Y")
        click_on('Update School')

        expect(school.observations.first.description.to_s).to include("became an active user of Energy Sparks!")

        school.reload
        expect(school.activation_date).to eq activation_date

        click_on('Edit school details')
        fill_in 'Activation date', with: ''
        click_on('Update School')

        school.reload
        expect(school.activation_date).to eq nil
      end
    end
  end
end
