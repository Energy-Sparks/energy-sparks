require 'rails_helper'

describe 'temperature recordings as school admin' do

  let(:school_name) { 'Active school'}
  let!(:school)     { create(:school, name: school_name) }

  context 'as a pupil' do

    let!(:user)       { create(:pupil, school: school)}

    before(:each) do
      sign_in(user)
      visit root_path
      click_on 'Enter temperatures'
    end


    context 'adding recordings' do

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

      it 'keeps hold of any partially entered data which fails validation as this was failing under certain circumstances' do
        fill_in 'observation_temperature_recordings_attributes_0_location_attributes_name', with: 'The Hall'
        fill_in 'observation_temperature_recordings_attributes_0_centigrade', with: 150
        expect { click_on('Create temperature recordings') }.to change { Observation.count }.by(0).and change { TemperatureRecording.count }.by(0).and change { Location.count }.by(0)
        expect { click_on('Create temperature recordings') }.to change { Observation.count }.by(0).and change { TemperatureRecording.count }.by(0).and change { Location.count }.by(0)
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

    context 'manage locations' do
      it "allows a user to create a location on it's own" do
        location_name = 'ABCDEF'
        click_on 'Manage locations and rooms'
        click_on 'Add new location'
        fill_in :location_name, with: location_name
        expect { click_on 'Create' }.to change { Location.count }.by(1)
      end

      it "allows a user to delete a location on it's own" do
        location_name = 'ABCDEF'
        Location.create(school: school, name: location_name)
        click_on 'Manage locations and rooms'
        expect(page).to have_content(location_name)
        expect { click_on 'Delete' }.to change { Location.count }.by(-1)
      end

      it "allows a user to edit a location on it's own" do
        location_name = 'ABCDEF'
        new_location_name = 'GAGA'
        Location.create(school: school, name: location_name)
        click_on 'Manage locations and rooms'
        expect(page).to have_content(location_name)
        expect(page).to_not have_content(new_location_name)
        click_on 'Edit'
        fill_in :location_name, with: new_location_name
        click_on 'Update Location'

        expect(page).to_not have_content(location_name)
        expect(page).to have_content(new_location_name)
        expect(page).to have_content('Location updated')
      end

      it 'deletes an assocated temperature recording if location is nobbled' do
        observation = create(:observation_with_temperature_recording_and_location, school: school)
        click_on 'Manage locations and rooms'
        expect(page).to have_content(observation.locations.first.name)
        expect { click_on 'Delete' }.to change { Location.count }.by(-1).and change { TemperatureRecording.count }.by(-1)
      end
    end
  end

  context 'deleting a temperature recording as admin' do

    let!(:user)       { create(:school_admin, school: school)}
    let!(:observation)  { create(:observation_with_temperature_recording_and_location, school: school) }

    before(:each) do
      sign_in(user)
      visit root_path
      click_on 'Pupil dashboard'
      click_on 'Previous temperatures'
    end

    it 'allows an observation to be deleted, which deletes temperature recordings, but not locations' do
      expect { click_on('Delete') }.to change { Observation.count }.by(-1).and change { TemperatureRecording.count }.by(-1).and change { Location.count }.by(0)
    end
  end
end
