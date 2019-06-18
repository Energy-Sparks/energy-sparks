require 'rails_helper'

describe 'deleting a temperature recording as admin' do

  let(:school_name)   { 'Active school'}
  let(:school)        { create(:school, name: school_name) }
  let!(:user)         { create(:user, role: 'admin', school: school)}
  let!(:observation)  { create(:observation_with_temperature_recording_and_location, school: school) }

  before(:each) do
    sign_in(user)
    visit root_path
    click_on 'Pupil dashboard'
    click_on 'Previous temperatures'
  end

  it 'allows an observation to be deleted, which deletes temperature recordings, but not locations' do
 #   click_on('Delete')
    # expect(Observation.count).to be 0
    # expect(TemperatureRecording.count).to be 0
    # expect(Location.count).to be 1
    expect { click_on('Delete') }.to change { Observation.count }.by(-1).and change { TemperatureRecording.count }.by(-1).and change { Location.count }.by(0)
  end

end
