require 'rails_helper'


describe 'adding interventions' do

  let!(:school)     { create(:school, :with_calendar_area, weather_underground_area: create(:weather_underground_area), solar_pv_tuos_area: create(:solar_pv_tuos_area)) }
  let!(:user)       { create(:user, role: :school_admin, school: school)}

  let!(:boiler_intervention){ create :intervention_type, title: 'Changed boiler' }

  before(:each) do
    sign_in(user)
  end

  it 'allows a user to add and edit interventions' do

    visit teachers_school_path(school)

    click_on 'Record an energy saving action'

    click_on boiler_intervention.intervention_type_group.title

    fill_in 'Start date', with: '01/07/2019'
    choose 'Changed boiler'
    fill_in 'Describe what was done', with: 'We changed to a more efficient boiler'
    click_on 'Confirm'

    intervention = school.observations.intervention.first
    expect(intervention.intervention_type).to eq(boiler_intervention)
    expect(intervention.at.to_date).to eq(Date.new(2019, 7, 1))

    within '.application' do
      click_on 'Edit'
    end

    fill_in 'Start date', with: '20/06/2019'
    click_on 'Confirm'

    intervention.reload
    expect(intervention.at.to_date).to eq(Date.new(2019, 6, 20))

    click_on 'Changed boiler'
    expect(page).to have_content('We changed to a more efficient boiler')

  end

  it 'destroys interventions' do
    intervention = create(:observation, :intervention, school: school)

    visit teachers_school_path(school)
    click_on 'View all actions'

    expect{
      click_on 'Delete'
    }.to change{Observation.count}.from(1).to(0)
  end

end
