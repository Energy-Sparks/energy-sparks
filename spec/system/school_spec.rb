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
    expect(page.has_content? "Participating Schools").to be true
    click_on(school_name)
    expect(page.has_content? school_name).to be true
    expect(page.has_no_content? "Gas").to be true
  end

  describe 'when logged in' do
    before(:each) do
      sign_in(admin)
      visit root_path
      expect(page.has_content? 'Sign Out').to be true
      click_on('Schools')
      expect(page.has_content? "Participating Schools").to be true
    end

    describe 'school with gas meter' do
      it 'shows me a school page' do
        school.configuration.update(gas_dashboard_chart_type: Schools::Configuration::TEACHERS_GAS_SIMPLE)
        click_on(school_name)
        expect(page.has_content? "Gas").to be true
        expect(page.has_content? "Electricity").to be false
      end
    end

    describe 'school with both meters' do
      it 'shows me a school page with both meters' do
        school.configuration.update(gas_dashboard_chart_type: Schools::Configuration::TEACHERS_GAS_SIMPLE, fuel_configuration: Schools::FuelConfiguration.new(has_electricity: true, has_gas: true))
        click_on(school_name)
        expect(page.has_content? school_name).to be true
        expect(page.has_content? "Gas").to be true
        expect(page.has_content? "Electricity").to be true
      end
    end

    describe 'school management' do

      it 'I can set up a school for KS1' do
        click_on(school_name)
        click_on('Edit school')
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
        click_on('Edit')
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

      it 'allows me to set a school group for the school' do
        group = create(:school_group, name: 'BANES', scoreboard: create(:scoreboard))
        click_on(school_name)
        click_on('Manage groups')
        select 'BANES', from: 'Group'
        click_on 'Update groups'
        school.reload
        expect(school.school_group).to eq(group)
      end

      it 'only allows selection on groups with the same academic years' do
        regional_calendar = create(:regional_calendar)
        school_calendar = create(:school_calendar, based_on: regional_calendar)
        school.update!(calendar: school_calendar, template_calendar: regional_calendar)

        create(:school_group, name: 'BANES', scoreboard: create(:scoreboard, academic_year_calendar: regional_calendar.based_on))
        create(:school_group, name: 'Oxford', scoreboard: create(:scoreboard))

        click_on(school_name)
        click_on('Manage groups')

        expect(page).to have_select('Group', :options => ['', 'BANES'])
      end

      it 'allows activation from school page' do
        school.update(active: false)
        click_on(school_name)
        click_on('Activate school')
        school.reload
        expect(school).to be_active
      end

      it 'allows activation and deactivation' do
        click_on(school_name)
        click_on('Edit')
        click_on('Deactivate school')
        school.reload
        expect(school).to_not be_active
        click_on('Activate school')
        school.reload
        expect(school).to be_active
      end
    end
  end
end
