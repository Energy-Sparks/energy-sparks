require 'rails_helper'

describe 'DarkSkyTemperatureReading' do
  let!(:area) { create(:dark_sky_area) }
  let!(:reading_1) { create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-01-01') }
  let!(:reading_2) { create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-02-01') }

  it 'applies date scope' do
    expect(area.dark_sky_temperature_readings.since(Date.new(2018, 0o1, 0o1))).to eq([reading_1, reading_2])
    expect(area.dark_sky_temperature_readings.since(Date.new(2019, 0o2, 0o1))).to eq([reading_2])
    expect(area.dark_sky_temperature_readings.since(Date.new(2019, 0o2, 0o2))).to eq([])
  end
end
