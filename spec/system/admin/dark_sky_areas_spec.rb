require 'rails_helper'

RSpec.describe 'Dark sky areas', type: :system do
  let!(:admin)                  { create(:admin) }
  let(:title)                   { 'Lights out for darker skies' }
  let(:latitude)                { 123.456 }
  let(:longitude)               { -789.012 }
  let(:back_fill_years)         { 5 }

  describe 'when logged in' do
    before(:each) do
      sign_in(admin)
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
      click_on 'Dark Sky Areas'
    end

    it 'can create a new dark sky area' do
      expect(page).to have_content("There are no Dark Sky Areas")

      click_on 'New Dark Sky Area'

      fill_in 'Title', with: title
      fill_in 'Latitude', with: latitude
      fill_in 'Longitude', with: longitude
      fill_in 'Back fill years', with: back_fill_years

      expect { click_on 'Create' }.to change { DarkSkyArea.count }.by(1)

      expect(page).to have_content("New Dark Sky Area created")
      expect(page).to have_content('Dark Sky Areas')
      expect(page).to have_content title
      expect(page).to have_content latitude
      expect(page).to have_content longitude
      expect(page).to have_content back_fill_years
    end

    it 'checks for valid fields' do
      click_on 'New Dark Sky Area'

      fill_in 'Title', with: title
      fill_in 'Latitude', with: latitude

      expect { click_on 'Create' }.to change { DarkSkyArea.count }.by(0)

      expect(page).to have_content("can't be blank")

      fill_in 'Longitude', with: longitude
      expect { click_on 'Create' }.to change { DarkSkyArea.count }.by(1)

      expect(page).to have_content('Dark Sky Areas')
      expect(page).to have_content title
      expect(page).to have_content latitude
      expect(page).to have_content longitude
    end

    context 'with an existing dark sky area' do

      let!(:area) { DarkSkyArea.create!(title: title, latitude: latitude, longitude: longitude) }

      before(:each) do
        click_on 'Manage'
        click_on 'Admin'
        click_on 'Dark Sky Areas'

        expect(DarkSkyArea.count).to be 1
        expect(page).to have_content('Dark Sky Areas')
        expect(page).to have_content title
        expect(page).to have_content latitude
        expect(page).to have_content longitude
      end

      it 'can be edited' do
        expect(DarkSkyArea.count).to be 1
        click_on 'Edit'

        new_latitude = 111.111
        new_longitude = 999.999
        new_back_fill_years = 5
        fill_in 'Latitude', with: new_latitude
        fill_in 'Longitude', with: new_longitude
        fill_in 'Back fill years', with: new_back_fill_years

        click_on 'Update'

        expect(page).to have_content("Dark Sky Area was updated")

        expect(page).to have_content('Dark Sky Areas')
        expect(page).to have_content title
        expect(page).to have_content new_latitude
        expect(page).to have_content new_longitude
        expect(page).to have_content new_back_fill_years
      end

      it 'checks for valid fields on update' do
        click_on 'Edit'

        new_latitude = 111.111
        new_longitude = 999.999

        fill_in 'Latitude', with: ''
        fill_in 'Longitude', with: new_longitude

        click_on 'Update'

        expect(page).to have_content("can't be blank")

        fill_in 'Latitude', with: new_latitude

        click_on 'Update'
        expect(page).to have_content("Dark Sky Area was updated")

        expect(page).to have_content('Dark Sky Areas')
        expect(page).to have_content title
        expect(page).to have_content new_latitude
        expect(page).to have_content new_longitude
      end

      it 'deletes old temperature readings if lat/long changed' do

        DataFeeds::DarkSkyTemperatureReading.create!(
          reading_date: '2020-03-25',
          temperature_celsius_x48: 48.times.map{rand(40.0)},
          area_id: area.id
        )

        expect(area.dark_sky_temperature_readings.count).to eq(1)

        click_on 'Edit'

        new_title = 'New title for this area'
        new_latitude = 111.111
        new_longitude = 999.999

        fill_in 'Title', with: new_title

        click_on 'Update'

        expect(page).to have_content("Dark Sky Area was updated")
        expect(page).to have_content new_title
        expect(area.dark_sky_temperature_readings.count).to eq(1)

        click_on 'Edit'

        fill_in 'Latitude', with: new_latitude
        fill_in 'Longitude', with: new_longitude

        click_on 'Update'

        expect(page).to have_content("Dark Sky Area was updated")
        expect(page).to have_content new_latitude
        expect(page).to have_content new_longitude
        expect(area.dark_sky_temperature_readings.count).to eq(0)

      end
    end
  end
end
