require 'rails_helper'

RSpec.describe "school onboarding", :schools, type: :system do

  let(:school_name) { 'Oldfield Park Infants'}
  let!(:admin)  { create(:user, role: 'admin')}

  let!(:calendar_area){ create(:calendar_area, title: 'BANES calendar') }
  let!(:calendar){ create(:calendar_with_terms, calendar_area: calendar_area, template: true) }
  let!(:solar_pv_area){ create(:solar_pv_tuos_area, title: 'BANES solar') }
  let!(:weather_underground_area){ create(:weather_underground_area, title: 'BANES weather') }
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

    before(:each) do
      sign_in(admin)
      visit root_path
    end

    it 'records basic details and sends an email to the school' do
      within '.navbar' do
        click_on 'School Onboarding'
      end
      click_on 'Onboard New School'

      fill_in 'School name', with: "St Mary's School"
      fill_in 'Contact email', with: 'stmarys@test.com'

      select 'BANES', from: 'Group'
      click_on 'Next'

      expect(page).to have_select('Calendar Area', selected: 'BANES calendar')
      expect(page).to have_select('Weather Underground Data Feed Area', selected: 'BANES weather')
      expect(page).to have_select('Solar PV from The University of Sheffield Data Feed Area', selected: 'BANES solar')

      click_on 'Next'

      expect(page).to have_content("St Mary's School")
      expect(page).to have_content("stmarys@test.com")

      click_on "Send onboarding email"

      onboarding = SchoolOnboarding.first

      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to include('Set up your school on Energy Sparks')
      expect(email.html_part.body.to_s).to include(onboarding_path(onboarding.uuid))

    end

  end
end

