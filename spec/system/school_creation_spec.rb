require 'rails_helper'

RSpec.describe "school creation", :schools, type: :system do

  let(:school_name) { 'Oldfield Park Infants'}
  let!(:admin)  { create(:user, role: 'admin')}

  let!(:ks1_tag) { ActsAsTaggableOn::Tag.create(name: 'KS1') }
  let!(:ks1_tagging) { ActsAsTaggableOn::Tagging.create(tag_id: ks1_tag.id, taggable_type: nil, taggable_id: nil, context: 'key_stages') }

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

  before(:each) do
    sign_in(admin)
    visit root_path
  end

  it 'splits the journey up in to basic details and configuration' do
    within '.navbar' do
      click_on 'New School'
    end

    fill_in 'Name', with: "St Mary's School"
    fill_in 'Unique Reference Number', with: '4444244'
    fill_in 'Number of pupils', with: 300
    fill_in 'Floor area in square metres', with: 400
    fill_in 'Address', with: '1 Station Road'
    fill_in 'Postcode', with: 'A1 2BC'

    choose 'Primary'
    check 'KS1'

    click_on 'Next'

    select 'BANES', from: 'Group'
    click_on 'Next'

    expect(page).to have_select('Calendar Area', selected: 'BANES calendar')
    expect(page).to have_select('Weather Underground Data Feed Area', selected: 'BANES weather')
    expect(page).to have_select('Solar PV from The University of Sheffield Data Feed Area', selected: 'BANES solar')

    click_on 'Next'

    expect(page).to have_content("Manage meters: St Mary's School")

    school = School.where(urn: '4444244').first
    expect(school.key_stage_list).to eq(['KS1'])
    expect(school.school_group).to eq(school_group)
    expect(school.calendar_area).to eq(calendar_area)
    expect(school.solar_pv_tuos_area).to eq(solar_pv_area)
    expect(school.weather_underground_area).to eq(weather_underground_area)
  end

end

