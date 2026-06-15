require 'rails_helper'

RSpec.describe WeatherStation, type: :model do
  let!(:station) { create(:weather_station) }
  let!(:station_inactive) { create(:weather_station, active: false)}

  it 'applies active by type scope' do
    expect(WeatherStation.count).to be 2
    expect(WeatherStation.by_provider('meteostat').to_a).to eql([station, station_inactive])
    expect(WeatherStation.active_by_provider('meteostat').to_a).to eql([station])
  end

  context 'with observations' do
    it 'counts correctly' do
      expect(station.observation_count).to be 0
      create(:weather_observation, weather_station: station)
      expect(WeatherObservation.count).to be 1
      expect(station.observation_count).to be 1
    end

    it 'formats earliest' do
      create(:weather_observation, weather_station: station, reading_date: Date.yesterday)
      create(:weather_observation, weather_station: station, reading_date: Time.zone.today)
      expect(station.earliest_observation_date).to eql(Date.yesterday)
    end

    it 'formats latest' do
      create(:weather_observation, weather_station: station, reading_date: Date.yesterday)
      create(:weather_observation, weather_station: station, reading_date: Time.zone.today)
      expect(station.latest_observation_date).to eql(Time.zone.today)
    end
  end
end
