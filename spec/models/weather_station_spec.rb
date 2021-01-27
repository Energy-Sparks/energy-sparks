require 'rails_helper'

RSpec.describe WeatherStation, type: :model do

  let!(:station) { create(:weather_station) }
  let!(:station_inactive) { create(:weather_station, active: false)}

  it 'applies active by type scope' do
    expect(WeatherStation.count).to eql 2
    expect( WeatherStation.by_provider("meteostat").to_a ).to eql([station, station_inactive])
    expect( WeatherStation.active_by_provider("meteostat").to_a).to eql([station])
  end
end
