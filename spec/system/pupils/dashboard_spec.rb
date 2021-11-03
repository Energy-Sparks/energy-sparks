require 'rails_helper'

describe 'Pupil dashboard' do

  let(:school_name)         { 'Theresa Green Infants'}
  let!(:school_group)       { create(:school_group) }
  let!(:regional_calendar)  { create(:regional_calendar) }
  let!(:calendar)           { create(:school_calendar, based_on: regional_calendar) }
  let!(:school)             { create(:school, :with_feed_areas, calendar: calendar, name: school_name, school_group: school_group) }
  let!(:intervention)       { create(:observation, school: school) }

  let(:equivalence_type)          { create(:equivalence_type, time_period: :last_week )}
  let(:equivalence_type_content)  { create(:equivalence_type_content_version, equivalence_type: equivalence_type, equivalence: 'Your school spent {{gbp}} on electricity last year!')}
  let!(:equivalence)              { create(:equivalence, school: school, content_version: equivalence_type_content, data: {'gbp' => {'formatted_equivalence' => '£2.00'}}, to_date: Date.today ) }

  let(:pupil) { create(:pupil, school: school)}

  context 'when viewing as guest user' do
    before(:each) do
      visit pupils_school_path(school)
    end

    it 'shows login form'

    it 'shows equivalences' do
      expect(page).to have_content('Your school spent £2.00 on electricity last year!')
    end

    context 'for non-public school' do
      before(:each) do
        school.update!(public: false)
      end

      it 'prompts for login' do
        visit pupils_school_path(school)
        expect(page.has_content? 'This school has disabled public access').to be true
      end
    end

  end

  context 'when logged in as pupil' do
    before(:each) do
      sign_in(pupil)
      visit pupils_school_path(school)
    end

    it 'redirects to pupil dashboard' do
      visit root_path
      expect(page).to have_content("#{school.name}")
      expect(page).to have_title("Pupil dashboard")
    end

    it 'shows equivalences' do
      expect(page).to have_content('Your school spent £2.00 on electricity last year!')
    end

    it 'has navigation to adult dashboard' do
      expect(page).to have_content("#{school.name}")
      click_on 'Adult dashboard'
      expect(page).to have_title("Adult dashboard")
      click_on 'Pupil dashboard'
      expect(page).to have_title("Pupil dashboard")
    end

    context 'with observations' do
      before(:each) do
        intervention_type = create(:intervention_type, title: 'Upgraded insulation')
        create(:observation, :intervention, school: school, intervention_type: intervention_type)
        create(:observation_with_temperature_recording_and_location, school: school)
        activity_type = create(:activity_type) # doesn't get saved if built with activity below
        create(:activity, school: school, activity_type: activity_type)
        visit pupils_school_path(school)
      end

      it 'displays interventions and temperature recordings in a timeline' do
        expect(page).to have_content('Recorded temperatures in')
        expect(page).to have_content('Upgraded insulation')
        expect(page).to have_content('Completed an activity')
        click_on 'View all actions'
        expect(page).to have_content('Recorded temperatures in')
        expect(page).to have_content('Upgraded insulation')
        expect(page).to have_content('Completed an activity')
      end
    end

    it 'hides old equivalences' do
      expect(equivalence.content_version.equivalence_type.time_period).to eq 'last_week'
      equivalence.update!(to_date: 50.days.ago)
      visit pupils_school_path(school)
      expect(page).to have_content(school_name)
      expect(page).to_not have_content('Your school spent £2.00 on electricity last year!')
    end

    it "hides old equivalences unless it's an old academic year one" do
      expect(equivalence.content_version.equivalence_type.time_period).to eq 'last_week'
      equivalence.update!(to_date: 50.days.ago)
      equivalence_type.update!(time_period: :last_academic_year)
      visit pupils_school_path(school)
      expect(page).to have_content(school_name)
      expect(page).to have_content('Your school spent £2.00 on electricity last year!')
    end
  end

  context 'when school is not data-enabled' do
    before(:each) do
      school.update!(data_enabled: false)
      visit pupils_school_path(school)
    end
    it 'doesnt show equivalences' do
      expect(page).to_not have_content('Your school spent £2.00 on electricity last year!')
    end

  end
end
