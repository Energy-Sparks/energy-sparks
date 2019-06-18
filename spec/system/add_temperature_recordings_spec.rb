require 'rails_helper'

describe 'adding a new temperature recording as admin' do

  let(:school_name) { 'Active school'}
  let!(:school)     { create(:school, name: school_name) }
  let!(:user)       { create(:user, role: 'admin', school: school)}

  before(:each) do
    sign_in(user)
    visit root_path
    click_on 'Pupil dashboard'
    click_on 'Enter temperatures'
  end

  it 'allows an observation to be added' do
    fill_in 'Temperature', match: :first, with: 20
    fill_in 'Place', match: :first, with: 'Hall'
    expect { click_on('Create temperature recordings') }.to change { Observation.count }.by(1).and change { TemperatureRecording.count }.by(1).and change { Location.count }.by(1)
    expect(page).to have_content('Temperature recordings')
  end

  it 're-uses existing locations' do
    fill_in 'Temperature', match: :first, with: 20
    fill_in 'Place', match: :first, with: 'Hall'
    click_on('Create temperature recordings')
    expect(Location.count).to be 1
    click_on('Add new temperature recordings')
    fill_in 'Temperature', match: :first, with: 20
    fill_in 'Place', match: :first, with: 'Hall'
    click_on('Create temperature recordings')
    expect(Observation.count).to be 2
    expect(TemperatureRecording.count).to be 2
    expect(Location.count).to be 1
  end

  it 'shows auto complete location suggestions', js: true do
    Location.create(school: school, name: 'ABCDEF')
    Location.create(school: school, name: 'GHIJKL')

    expect(school.locations.count).to be 2

    refresh

    fill_in 'Temperature', match: :first, with: 20
    fill_in 'Place', match: :first, with: 'AB'
    expect(page).to have_content('ABCDEF')
  end

  it 'validates at and takes you back without losing data' do
    fill_in 'Temperature', match: :first, with: 20
    fill_in 'Place', match: :first, with: 'Hall'
    fill_in 'At', with: ''
    expect { click_on('Create temperature recordings') }.to change { Observation.count }.by(0).and change { TemperatureRecording.count }.by(0).and change { Location.count }.by(0)

    fill_in 'At', with: Date.tomorrow
    expect { click_on('Create temperature recordings') }.to change { Observation.count }.by(0).and change { TemperatureRecording.count }.by(0).and change { Location.count }.by(0)
    fill_in 'At', with: Date.yesterday
    expect { click_on('Create temperature recordings') }.to change { Observation.count }.by(1).and change { TemperatureRecording.count }.by(1).and change { Location.count }.by(1)
  end

  it 'keeps hold of any partially entered data which fails validation' do
    fill_in 'observation_temperature_recordings_attributes_1_location_attributes_name', with: 'Hall'
    fill_in 'observation_temperature_recordings_attributes_0_centigrade', with: 20
    expect { click_on('Create temperature recordings') }.to change { Observation.count }.by(0).and change { TemperatureRecording.count }.by(0).and change { Location.count }.by(0)
    fill_in 'observation_temperature_recordings_attributes_0_location_attributes_name', with: 'Kitchen'
    fill_in 'observation_temperature_recordings_attributes_1_centigrade', with: 18
    expect { click_on('Create temperature recordings') }.to change { Observation.count }.by(1).and change { TemperatureRecording.count }.by(2).and change { Location.count }.by(2)
  end
end
