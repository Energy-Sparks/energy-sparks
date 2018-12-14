require 'rails_helper'

RSpec.describe "school onboarding", :schools, type: :system do

  let(:school_name) { 'Oldfield Park Infants'}

  let(:calendar_area){ create(:calendar_area, title: 'BANES calendar') }
  let!(:calendar){ create(:calendar_with_terms, calendar_area: calendar_area, template: true) }
  let(:solar_pv_area){ create(:solar_pv_tuos_area, title: 'BANES solar') }
  let(:weather_underground_area){ create(:weather_underground_area, title: 'BANES weather') }
  let!(:school_group) do
    create(
      :school_group,
      name: 'BANES',
      default_calendar_area: calendar_area,
      default_solar_pv_tuos_area: solar_pv_area,
      default_weather_underground_area: weather_underground_area
    )
  end


  context 'as an admin' do

    let!(:admin)  { create(:user, role: 'admin')}

    before(:each) do
      sign_in(admin)
      visit root_path
    end

    it 'records basic details and sends an email to the school' do
      within '.navbar' do
        click_on 'School Onboarding'
      end
      click_on 'Onboard New School'

      fill_in 'School name', with: school_name
      fill_in 'Contact email', with: 'oldfield@test.com'

      select 'BANES', from: 'Group'
      click_on 'Next'

      expect(page).to have_select('Calendar Area', selected: 'BANES calendar')
      expect(page).to have_select('Weather Underground Data Feed Area', selected: 'BANES weather')
      expect(page).to have_select('Solar PV from The University of Sheffield Data Feed Area', selected: 'BANES solar')

      click_on 'Next'

      expect(page).to have_content(school_name)
      expect(page).to have_content("oldfield@test.com")

      click_on "Send onboarding email"

      onboarding = SchoolOnboarding.first

      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to include('Set up your school on Energy Sparks')
      expect(email.html_part.body.to_s).to include(onboarding_path(onboarding.uuid))
    end
  end

  context 'as school user signing up' do

    let!(:ks1_tag) { ActsAsTaggableOn::Tag.create(name: 'KS1') }
    let!(:ks1_tagging) { ActsAsTaggableOn::Tagging.create(tag_id: ks1_tag.id, taggable_type: nil, taggable_id: nil, context: 'key_stages') }

    let!(:onboarding) do
      create(
        :school_onboarding, :with_events,
        event_names: [:email_sent],
        school_name: school_name,
        calendar_area: calendar_area
      )
    end

    before(:each) do
      visit onboarding_path(onboarding.uuid)
    end

    it 'walks the user through the steps required' do
      expect(page).to have_content('Welcome to Energy Sparks')
      click_on 'Next'

      click_on 'I give permission'

      onboarding.reload
      expect(onboarding).to have_event('permission_given')

      expect(page).to have_field('Email', with: onboarding.contact_email)
      fill_in 'Your name', with: 'A Teacher'
      fill_in 'Password', with: 'testtest1'
      click_on 'Create my account'

      onboarding.reload
      expect(onboarding.created_user.name).to eq('A Teacher')
      expect(onboarding.created_user.role).to eq('school_onboarding')

      fill_in 'Unique Reference Number', with: '4444244'
      fill_in 'Number of pupils', with: 300
      fill_in 'Floor area in square metres', with: 400
      fill_in 'Address', with: '1 Station Road'
      fill_in 'Postcode', with: 'A1 2BC'

      choose 'Primary'
      check 'KS1'

      click_on 'Update school details'

      # TODO: show details/edit?

      click_on "I've finished"
      expect(onboarding).to have_event(:onboarding_complete)

      expect(page).to have_content("We'll have a look at school details you've sent us and let you know when your school goes live.")
    end

    it 'lets the user edit inset days, meters and opening times but does not require them' do
      create :calendar_event_type, title: 'Teacher training', inset_day: true
      academic_year = create :academic_year, start_date: Date.new(2018, 9,1), end_date: Date.new(2019, 8, 31)
      user = create(:user, role: 'school_onboarding')
      onboarding.update!(created_user: user)
      school = build(:school)
      SchoolCreator.new(school).onboard_school!(onboarding)

      sign_in(user)

      visit new_onboarding_completion_path(onboarding.uuid)

      # Meters
      expect(page).to have_content('Meters: 0')
      click_on 'Add a meter'
      fill_in 'Meter Point Number', with: '123543'
      fill_in 'Meter Name', with: 'Gas'
      choose 'Gas'
      click_on 'Create Meter'
      expect(page).to have_content('Meters: 1')

      # Opening times
      expect(page).to have_content('Monday 08:50 - 15:20')
      click_on 'Set school times'
      fill_in 'monday-opening_time', with: '900'
      click_on 'Update school times'
      expect(page).to have_content('Monday 09:00 - 15:20')

      pending

      # Inset days
      expect(page).to have_content('Inset days: 0')
      click_on 'Add inset day'
      fill_in 'Title', with: 'Teacher training'
      select 'Teacher training', from: 'Type'
      fill_in 'Date', with: '7/1/2019'
      click_on 'Add inset day'

      # Other users
    end

  end
end

