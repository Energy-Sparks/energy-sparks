require 'rails_helper'

describe 'Pupil dashboard' do

  let(:school_name)         { 'Theresa Green Infants'}
  let!(:school_group)       { create(:school_group) }
  let!(:regional_calendar)  { create(:regional_calendar) }
  let!(:calendar)           { create(:school_calendar, based_on: regional_calendar) }
  let!(:school)             { create(:school, :with_feed_areas, calendar: calendar, name: school_name, school_group: school_group) }
  let!(:intervention)       { create(:observation, school: school) }

  let(:pupil) { create(:pupil, school: school)}

  context 'when logged in as pupil' do
    before(:each) do
      sign_in(pupil)
    end

    it 'allows login and access to dashboard' do
      visit root_path
      expect(page).to have_content("#{school.name}")
      click_on 'Adult dashboard'
      expect(page).to have_title("Adult dashboard")
      click_on 'Pupil dashboard'
      expect(page).to have_title("Pupil dashboard")
    end

    it 'displays interventions and temperature recordings in a timeline' do
      intervention_type = create(:intervention_type, title: 'Upgraded insulation')
      create(:observation, :intervention, school: school, intervention_type: intervention_type)
      create(:observation_with_temperature_recording_and_location, school: school)
      activity_type = create(:activity_type) # doesn't get saved if built with activity below
      create(:activity, school: school, activity_type: activity_type)

      visit pupils_school_path(school)
      expect(page).to have_content('Recorded temperatures in')
      expect(page).to have_content('Upgraded insulation')
      expect(page).to have_content('Completed an activity')
      click_on 'View all actions'
      expect(page).to have_content('Recorded temperatures in')
      expect(page).to have_content('Upgraded insulation')
      expect(page).to have_content('Completed an activity')
    end
  end
end
