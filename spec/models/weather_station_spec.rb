require 'rails_helper'

RSpec.describe WeatherStation, type: :model do

  let!(:station) { create(:weather_station) }
  let!(:station_inactive) { create(:weather_station, active: false)}

  it 'applies active by type scope' do
    expect(WeatherStation.count).to eql 2
    expect( WeatherStation.by_provider("meteostat").to_a ).to eql([station, station_inactive])
    expect( WeatherStation.active_by_provider("meteostat").to_a).to eql([station])
  end

  context "with observations" do

    it "counts correctly" do
      expect( station.observation_count ).to eql 0
      create(:weather_observation, weather_station: station)
      expect(WeatherObservation.count).to eql 1
      expect( station.observation_count ).to eql 1
    end

    it "formats earliest" do
      create(:weather_observation, weather_station: station, reading_date: Date.yesterday)
      create(:weather_observation, weather_station: station, reading_date: Date.today)
      expect( station.first_observation_date ).to eql(Date.yesterday.strftime('%d %b %Y'))
    end

    it "formats latest" do
      create(:weather_observation, weather_station: station, reading_date: Date.yesterday)
      create(:weather_observation, weather_station: station, reading_date: Date.today)
      expect( station.last_observation_date ).to eql(Date.today.strftime('%d %b %Y'))
    end

  end
end
