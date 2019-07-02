require 'rails_helper'


describe 'adding interventions' do

  let!(:school)     { create(:school, weather_underground_area: create(:weather_underground_area), solar_pv_tuos_area: create(:solar_pv_tuos_area)) }
  let!(:user)       { create(:user, role: :school_admin, school: school)}

  let!(:boiler_intervention){ create :intervention_type, title: 'Changed boiler' }

  before(:each) do
    sign_in(user)
  end

  it 'allows a user to add an intervention' do

    visit teachers_school_path(school)

    click_on 'Interventions'
    click_on 'New intervention'

    fill_in 'Date', with: '01/07/2019'
    select 'Changed boiler', from: 'Intervention'
    fill_in 'Notes', with: 'We changed to a more efficient boiler'
    click_on 'Create intervention'

    intervention = school.observations.intervention.first
    expect(intervention.intervention_type).to eq(boiler_intervention)
    expect(intervention.at.to_date).to eq(Date.new(2019, 7, 1))

  end

end
