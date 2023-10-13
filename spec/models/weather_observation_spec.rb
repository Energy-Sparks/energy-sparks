require 'rails_helper'

RSpec.describe WeatherObservation, type: :model do
  let!(:station) { create(:weather_station) }
  let!(:reading_1) { create(:weather_observation, weather_station: station, reading_date: '2020-01-01') }
  let!(:reading_2) { create(:weather_observation, weather_station: station, reading_date: '2021-01-01') }

  it 'applies date scope' do
    expect(station.weather_observations.by_date).to eq([reading_1, reading_2])
    expect(station.weather_observations.since(Date.new(2020, 0o2, 0o1))).to eq([reading_2])
    expect(station.weather_observations.since(Date.new(2021, 0o2, 0o1))).to eq([])
  end
end
