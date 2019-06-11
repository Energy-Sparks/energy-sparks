require 'rails_helper'

describe 'adding a new observation as admin' do

  let(:school_name) { 'Active school'}
  let!(:school)     { create(:school, name: school_name) }
  let!(:user)       { create(:user, role: 'admin', school: school)}
  let(:description) { 'Here is what we saw' }

  before(:each) do
    sign_in(user)
    visit root_path
    click_on 'Pupil dashboard'
    click_on 'Enter temperatures'
  end

  it 'allows an observation to be added' do
    fill_in 'What we did', with: description
    fill_in 'Temperature', match: :first, with: 20
    fill_in 'Place', match: :first, with: 'Hall'
    expect { click_on('Create temperature recordings') }.to change { Observation.count }.by(1).and change { TemperatureRecording.count }.by(1).and change { Location.count }.by(1)
    expect(page).to have_content('Temperature recordings')
    expect(page).to have_content(description)
  end

  it 'validates and takes you back without losing data' do
    fill_in 'Temperature', match: :first, with: 20
    fill_in 'Place', match: :first, with: 'Hall'
    expect { click_on('Create temperature recordings') }.to change { Observation.count }.by(0).and change { TemperatureRecording.count }.by(0).and change { Location.count }.by(0)
    fill_in 'What we did', with: description
    expect { click_on('Create temperature recordings') }.to change { Observation.count }.by(1).and change { TemperatureRecording.count }.by(1).and change { Location.count }.by(1)
  end
end
