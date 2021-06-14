require 'rails_helper'

RSpec.describe "school creation", :schools, type: :system do

  let(:school_name) { 'Oldfield Park Infants'}
  let!(:admin)  { create(:admin)}

  let!(:ks1) { KeyStage.create(name: 'KS1') }

  # This calendar is there to allow for the calendar area selection
  let!(:calendar)       { create(:template_calendar, title: 'BANES calendar') }
  let!(:solar_pv_area)  { create(:solar_pv_tuos_area, title: 'BANES solar') }
  let!(:dark_sky_area)  { create(:dark_sky_area, title: 'BANES dark sky weather') }
  let!(:scoreboard)     { create(:scoreboard, name: 'BANES scoreboard') }
  let!(:weather_station) { create(:weather_station, title: 'BANES weather')}

  let!(:school_group) do
    create(
      :school_group,
      name: 'BANES',
      default_template_calendar: calendar,
      default_solar_pv_tuos_area: solar_pv_area,
      default_dark_sky_area: dark_sky_area,
      default_weather_station: weather_station,
      default_scoreboard: scoreboard
    )
  end

  before(:each) do
    sign_in(admin)
    visit root_path
    click_on 'Admin'
  end

  it 'splits the journey up in to basic details and configuration' do
    click_on 'Manual School Setup'

    fill_in 'School name', with: "St Mary's School"
    fill_in 'Unique Reference Number', with: '4444244'
    fill_in 'Number of pupils', with: 300
    fill_in 'Floor area in square metres', with: 400
    fill_in 'Address', with: '1 Station Road'
    fill_in 'Postcode', with: 'A1 2BC'
    fill_in 'Website', with: 'http://stmarys.sch.uk'

    choose 'Primary'
    check 'KS1'

    click_on 'Next'

    select 'BANES', from: 'Group'
    click_on 'Next'

    expect(page).to have_select('Template calendar', selected: 'BANES calendar')
    expect(page).to have_select('Dark Sky Data Feed Area', selected: 'BANES dark sky weather')
    expect(page).to have_select('Weather Station', selected: 'BANES weather')
    expect(page).to have_select('Solar PV from The University of Sheffield Data Feed Area', selected: 'BANES solar')
    expect(page).to have_select('Scoreboard', selected: 'BANES scoreboard')

    click_on 'Next'

    expect(page).to have_content("St Mary's School")
    expect(page).to have_content("Meters")

    school = School.where(urn: '4444244').first
    expect(school.key_stages).to match_array([ks1])
    expect(school.school_group).to eq(school_group)
    expect(school.template_calendar).to eq(calendar)
    expect(school.solar_pv_tuos_area).to eq(solar_pv_area)
    expect(school.dark_sky_area).to eq(dark_sky_area)
    expect(school.scoreboard).to eq(scoreboard)
  end
end
