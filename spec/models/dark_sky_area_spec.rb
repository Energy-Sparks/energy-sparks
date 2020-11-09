require 'rails_helper'

describe 'DarkSkyAreaReading' do

  let!(:area) { create(:dark_sky_area, back_fill_years: 2) }
  let!(:reading_1) { create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2018-06-01') }
  let!(:reading_2) { create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2018-06-02') }
  let!(:reading_3) { create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-06-01') }
  let!(:reading_4) { create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-06-02') }

  it 'has sufficient readings when 2 required in each year' do
    expect(area.has_sufficient_readings?(Date.new(2020,06,01), 2)).to be true
  end

  it 'does not have sufficient readings when 3 required in each year' do
    expect(area.has_sufficient_readings?(Date.new(2020,06,01), 3)).to be false
  end

  it 'does not have sufficient readings when date range excludes earliest reading' do
    expect(area.has_sufficient_readings?(Date.new(2020,06,02), 2)).to be false
  end

end
