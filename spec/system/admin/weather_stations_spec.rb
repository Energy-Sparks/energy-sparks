require 'rails_helper'

RSpec.describe 'Weather stations', :include_application_helper, type: :system do
  let(:title)                   { 'Weather station zebra' }
  let(:description)             { 'The description'}
  let(:latitude)                { 123.456 }
  let(:longitude)               { -789.012 }
  let(:provider)                { 'Meteostat'}

  before do
    sign_in(create(:admin))
    visit root_path
    click_on 'Manage'
    click_on 'Admin'
    click_on 'Weather Stations'
  end

  it 'can create a new weather station' do
    expect(page).to have_content('There are no Weather Stations')

    click_on 'New Weather Station'

    fill_in 'Title', with: title
    fill_in 'Description', with: description
    fill_in 'Latitude', with: latitude
    fill_in 'Longitude', with: longitude
    select 'Meteostat', from: 'Provider'
    check 'Load data?'

    expect { click_on 'Create' }.to change(WeatherStation, :count).by(1)

    expect(page).to have_content('New Weather Station created')
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

    expect { click_on 'Create' }.to change(WeatherStation, :count).by(0)

    expect(page).to have_content("can't be blank")

    fill_in 'Longitude', with: longitude
    select 'Meteostat', from: 'Provider'
    check 'Load data?'
    expect { click_on 'Create' }.to change(WeatherStation, :count).by(1)

    expect(page).to have_content('Weather Stations')
    expect(page).to have_content title
    expect(page).to have_content latitude
    expect(page).to have_content longitude
  end

  context 'with an existing weather station' do
    let!(:station) { create(:weather_station, title: title, latitude: latitude, longitude: longitude, provider: 'meteostat') }

    before do
      click_on 'Manage'
      click_on 'Admin'
      click_on 'Weather Stations'
    end

    it 'displays the station' do
      expect(page).to have_content('Weather Stations')
      expect(page).to have_content title
      expect(page).to have_content latitude
      expect(page).to have_content longitude
      expect(page).to have_content('Report')
      expect(page).to have_content('CSV')
    end

    it 'can be edited' do
      click_on 'Edit'

      new_latitude = 111.111
      new_longitude = 999.999
      new_title = 'New title'
      new_description = 'New description'

      fill_in 'Title', with: new_title
      fill_in 'Description', with: new_description
      fill_in 'Latitude', with: new_latitude
      fill_in 'Longitude', with: new_longitude

      click_on 'Update'

      expect(page).to have_content('Weather Station was updated')

      expect(page).to have_content('Weather Stations')
      expect(page).to have_content new_title
      expect(page).to have_content new_description
      expect(page).to have_content new_latitude
      expect(page).to have_content new_longitude
    end

    it 'checks for valid fields on update' do
      click_on 'Edit'

      new_title = 'New title'

      fill_in 'Title', with: ''
      check('Load data?')

      click_on 'Update'

      expect(page).to have_content("can't be blank")

      fill_in 'Title', with: new_title

      click_on 'Update'
      expect(page).to have_content('Weather Station was updated')

      expect(page).to have_content('Weather Stations')
      expect(page).to have_content new_title
    end

    it 'deletes old temperature readings if lat/long changed' do
      WeatherObservation.create!(
        reading_date: '2020-03-25',
        temperature_celsius_x48: 48.times.map {rand(40.0)},
        weather_station_id: station.id
      )

      expect(station.weather_observations.count).to eq(1)

      click_on 'Edit'

      new_title = 'New title for this station'
      new_latitude = 111.111
      new_longitude = 999.999

      fill_in 'Title', with: new_title

      click_on 'Update'

      expect(page).to have_content('Weather Station was updated')
      expect(page).to have_content new_title
      expect(station.weather_observations.count).to eq(1)

      click_on 'Edit'

      fill_in 'Latitude', with: new_latitude
      fill_in 'Longitude', with: new_longitude

      click_on 'Update'

      expect(page).to have_content('Weather Station was updated')
      expect(page).to have_content new_latitude
      expect(page).to have_content new_longitude
      expect(station.weather_observations.count).to eq(0)
    end

    context 'when viewing report' do
      let!(:station) { create(:weather_station, :with_readings) }

      before do
        click_on 'Report'
      end

      it 'displays the report' do
        expect(page).to have_content(station.title)
        first_reading = station.weather_observations.by_date.first
        expect(page).to have_content("This report summarises the temperature data from #{nice_dates(first_reading.reading_date)}")
      end
    end
  end
end
