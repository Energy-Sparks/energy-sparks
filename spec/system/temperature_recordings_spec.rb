require 'rails_helper'

describe 'temperature recordings as school admin' do

  let(:school_name) { 'Active school'}
  let!(:school)     { create(:school, name: school_name) }

  let!(:the_hall){ create(:location, school: school, name: 'The Hall') }

  context 'as a pupil' do

    let!(:user)       { create(:pupil, school: school)}

    context 'when the site settings are turned off' do
      it 'does not show temperature recording links' do
        sign_in(user)
        visit root_path
        expect(page).to_not have_link('Enter temperatures')
      end
    end

    context 'when temperature recoding is turned on' do

      before(:each) do
        SiteSettings.create!(temperature_recording_months: (1..12).map(&:to_s))
        sign_in(user)
        visit root_path
        click_on 'Enter temperatures'
      end

      context 'adding recordings' do
        it 'displays the locations and allows the user to add a new one and then enter temperatures for the current locations' do
          expect(page).to have_content('The Hall')

          fill_in 'Name', with: 'Blue classroom'
          click_on 'Create Location'

          expect(page).to have_content('The Hall')
          expect(page).to have_content('Blue classroom')

          click_on 'Next'

          fill_in 'The Hall', with: 20
          fill_in 'Blue classroom', with: 13

          expect { click_on('Create temperature recordings') }.to change { Observation.count }.by(1).and change { TemperatureRecording.count }.by(2)
        end

        it 'validates at and takes you back without losing data' do
          click_on 'Next'

          fill_in 'The Hall', with: 20
          fill_in 'At', with: ''
          expect { click_on('Create temperature recordings') }.to change { Observation.count }.by(0).and change { TemperatureRecording.count }.by(0)

          fill_in 'At', with: Date.tomorrow
          expect { click_on('Create temperature recordings') }.to change { Observation.count }.by(0).and change { TemperatureRecording.count }.by(0)
          fill_in 'At', with: Date.yesterday
          expect { click_on('Create temperature recordings') }.to change { Observation.count }.by(1).and change { TemperatureRecording.count }.by(1)
        end

        it 'keeps hold of any partially entered data which fails validation' do
          click_on 'Next'
          fill_in 'The Hall', match: :first, with: 2000
          expect { click_on('Create temperature recordings') }.to change { Observation.count }.by(0).and change { TemperatureRecording.count }.by(0)
          expect(page).to have_field('The Hall', with: 2000)
        end

      end

      context 'manage locations' do
        it "allows a user to delete a location on it's own" do
          click_on 'Change room names'
          expect { click_on 'Delete' }.to change { Location.count }.by(-1)
        end

        it "allows a user to edit a location on it's own" do
          click_on 'Change room names'
          click_on 'Edit'
          fill_in :location_name, with: 'The Great Hall'
          click_on 'Update Location'

          expect(page).to_not have_content('The Hall')
          expect(page).to have_content('The Great Hall')
          expect(page).to have_content('Location updated')
        end

        it 'deletes an assocated temperature recording if location is nobbled' do
          observation = create(:observation).tap do |obs|
            create(:temperature_recording, observation: obs, location: the_hall)
          end
          click_on 'Change room names'
          expect(page).to have_content(observation.locations.first.name)
          expect { click_on 'Delete' }.to change { Location.count }.by(-1).and change { TemperatureRecording.count }.by(-1)
        end
      end
    end
  end

  context 'deleting a temperature recording as admin' do

    let!(:user)       { create(:school_admin, school: school)}
    let!(:observation) do
      create(:observation, school: school).tap do |obs|
        create(:temperature_recording, observation: obs, location: the_hall)
      end
    end

    before(:each) do
      SiteSettings.create!(temperature_recording_months: (1..12).map(&:to_s))
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
