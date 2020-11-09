require 'rails_helper'

describe 'DarkSkyTemperatureReading' do

  let!(:area) { create(:dark_sky_area) }
  let!(:reading_1) { create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-01-01') }
  let!(:reading_2) { create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-02-01') }

  it 'applies date scope' do
    expect(area.dark_sky_temperature_readings.since(Date.new(2018,01,01))).to eq([reading_1, reading_2])
    expect(area.dark_sky_temperature_readings.since(Date.new(2019,02,01))).to eq([reading_2])
    expect(area.dark_sky_temperature_readings.since(Date.new(2019,02,02))).to eq([])
  end

end