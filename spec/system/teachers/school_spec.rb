require 'rails_helper'

RSpec.describe "teachers school view", type: :system do

  let(:school_name) { 'Theresa Green Infants'}
  let!(:school_group)  { create(:school_group) }
  let!(:regional_calendar)  { create(:regional_calendar) }
  let!(:calendar)           { create(:school_calendar, based_on: regional_calendar) }
  let!(:school)             { create(:school, :with_feed_areas, calendar: calendar, name: school_name, school_group: school_group) }
  let!(:user)               { create(:school_admin, school: school)}

  before(:each) do
    sign_in(user)
  end


  it 'I can visit the teacher dashboard' do
    visit teachers_school_path(school)
    expect(page).to have_content(school_name)
    expect(page).to have_link("Compare schools")
  end

  it 'displays interventions and temperature recordings in a timeline' do
    intervention_type = create(:intervention_type, title: 'Upgraded insulation')
    create(:observation, :intervention, school: school, intervention_type: intervention_type)
    create(:observation_with_temperature_recording_and_location, school: school)
    activity_type = create(:activity_type) # doesn't get saved if built with activity below
    create(:activity, school: school, activity_type: activity_type)

    visit teachers_school_path(school)
    expect(page).to have_content('Recorded temperatures in')
    expect(page).to have_content('Upgraded insulation')
    expect(page).to have_content('Completed an activity')
    click_on 'View all actions'
    expect(page).to have_content('Recorded temperatures in')
    expect(page).to have_content('Upgraded insulation')
    expect(page).to have_content('Completed an activity')
  end

  describe 'when the school is gas only I can visit the teacher dashboard and it only shows me a ' do
    it 'gas chart' do
      school.configuration.update!(fuel_configuration: Schools::FuelConfiguration.new(has_gas: true, has_electricity: false), gas_dashboard_chart_type: Schools::Configuration::TEACHERS_GAS_SIMPLE)
      visit teachers_school_path(school)
      expect(page).to have_content('Gas')
      expect(page).to_not have_content 'Electricity'
    end
  end

  describe 'has a loading page which redirects to the right place', js: true do
    before(:each) do
      allow(AggregateSchoolService).to receive(:caching_off?).and_return(false, true)
      allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(school)
      allow_any_instance_of(ChartData).to receive(:data).and_return(nil)
    end

    context 'with a successful load' do
      before(:each) do
        allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(school)
        school.configuration.update(gas_dashboard_chart_type: Schools::Configuration::TEACHERS_GAS_SIMPLE)
      end
      it 'renders a loading page and then back to the dashboard page once complete' do
        visit teachers_school_path(school)

        expect(page).to have_content('Gas')
        # if redirect fails it will stille be processing
        expect(page).to_not have_content('processing')
        expect(page).to_not have_content("we're having trouble processing your energy data today")
      end
    end

    context 'with a loading error' do
      before(:each) do
        allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_raise(StandardError, 'It went wrong')
      end

      it 'shows an error message', errors_expected: true do
        visit teachers_school_path(school)

        expect(page).to have_content("we're having trouble processing your energy data today")
      end
    end
  end

  describe 'when the school is electricity only I can visit the teacher dashboard and it only shows me a ' do
    it 'electricity chart' do
      school.configuration.update!(fuel_configuration: Schools::FuelConfiguration.new(has_gas: false, has_electricity: true))
      visit teachers_school_path(school)
      expect(page).to have_content 'Electricity'
      expect(page).to_not have_content('Gas')
    end
  end
end

