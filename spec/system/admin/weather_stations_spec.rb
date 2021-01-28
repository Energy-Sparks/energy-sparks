require 'rails_helper'

RSpec.describe 'Weather stations', type: :system do
  let!(:admin)                  { create(:admin) }
  let(:title)                   { 'Weather station zebra' }
  let(:description)             { 'The description'}
  let(:latitude)                { 123.456 }
  let(:longitude)               { -789.012 }
  let(:provider)                { "Meteostat"}

  describe 'when logged in' do
    before(:each) do
      sign_in(admin)
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
      click_on 'Weather Stations'
    end

    it 'can create a new weather station' do
      expect(page).to have_content("There are no Weather Stations")

      click_on 'New Weather Station'

      fill_in 'Title', with: title
      fill_in 'Description', with: description
      fill_in 'Latitude', with: latitude
      fill_in 'Longitude', with: longitude
      select 'Meteostat', from: 'Provider'
      check 'Active'

      expect { click_on 'Create' }.to change { WeatherStation.count }.by(1)

      expect(page).to have_content("New Weather Station created")
      expect(page).to have_content('Weather Stations')
      expect(page).to have_content title
      expect(page).to have_content description
      expect(page).to have_content latitude
      expect(page).to have_content longitude
    end

    it 'checks for valid fields when creating a station' do
      click_on 'New Weather Station'

      fill_in 'Title', with: title
      fill_in 'Latitude', with: latitude

      expect { click_on 'Create' }.to change { WeatherStation.count }.by(0)

      expect(page).to have_content("can't be blank")

      fill_in 'Longitude', with: longitude
      select 'Meteostat', from: 'Provider'
      check 'Active'
      expect { click_on 'Create' }.to change { WeatherStation.count }.by(1)

      expect(page).to have_content('Weather Stations')
      expect(page).to have_content title
      expect(page).to have_content latitude
      expect(page).to have_content longitude
    end

    context 'with an existing weather station' do

      let!(:station) { WeatherStation.create!(title: title, latitude: latitude, longitude: longitude, provider: "meteostat") }

      before(:each) do
        click_on 'Manage'
        click_on 'Admin'
        click_on 'Weather Stations'

        expect(WeatherStation.count).to be 1
        expect(page).to have_content('Weather Stations')
        expect(page).to have_content title
        expect(page).to have_content latitude
        expect(page).to have_content longitude
      end

      it 'can be edited' do
        expect(WeatherStation.count).to be 1
        click_on 'Edit'

        new_latitude = 111.111
        new_longitude = 999.999
        new_title = "New title"
        new_description = "New description"

        fill_in 'Title', with: new_title
        fill_in 'Description', with: new_description
        fill_in 'Latitude', with: new_latitude
        fill_in 'Longitude', with: new_longitude

        click_on 'Update'

        expect(page).to have_content("Weather Station was updated")

        expect(page).to have_content('Weather Stations')
        expect(page).to have_content new_title
        expect(page).to have_content new_description
        expect(page).to have_content new_latitude
        expect(page).to have_content new_longitude
      end

      it 'checks for valid fields on update' do
        click_on 'Edit'

        new_title = "New title"

        fill_in 'Title', with: ''
        check('Active')

        click_on 'Update'

        expect(page).to have_content("can't be blank")

        fill_in 'Title', with: new_title

        click_on 'Update'
        expect(page).to have_content("Weather Station was updated")

        expect(page).to have_content('Weather Stations')
        expect(page).to have_content new_title
      end

    end
  end
end
