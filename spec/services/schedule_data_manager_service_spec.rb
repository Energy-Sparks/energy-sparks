require 'rails_helper'

describe ScheduleDataManagerService do
  include_context 'calendar data'

  describe 'calendar_cache_key' do
    let!(:school) { create(:school, calendar: calendar) }
    it 'generates a key' do
      expect(ScheduleDataManagerService.calendar_cache_key(calendar)).to include(calendar.id.to_s)
    end
  end

  describe 'invalidate_cached_calendar' do
    let!(:school) { create(:school, calendar: calendar) }
    it 'invalidates cache' do
      expect(Rails.cache).to receive(:delete)
      ScheduleDataManagerService.invalidate_cached_calendar(calendar)
    end
  end

  describe '#holidays' do
    let!(:school)                                    { create(:school, calendar: calendar) }
    let(:date_version_of_holiday_date_from_calendar) { Date.parse(random_before_holiday_start_date) }

    it 'assigns school date periods for the analytics code' do
      results = ScheduleDataManagerService.new(school).holidays
      school_date_period = results.find_holiday(date_version_of_holiday_date_from_calendar)
      expect(school_date_period.start_date).to eq date_version_of_holiday_date_from_calendar
      expect(school_date_period.type).to_not be_nil
    end
  end

  describe '#temperatures' do
    let!(:area)             { create(:dark_sky_area) }
    let!(:station)          { create(:weather_station) }
    let!(:school)           { create(:school, dark_sky_area: area, weather_station: station) }

    let!(:service)          { ScheduleDataManagerService.new(school) }

    it 'loads dark_sky data' do
      reading_1 = create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-01-01')
      reading_2 = create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-02-01')
      temperatures = service.temperatures
      expect(temperatures.start_date).to eql reading_1.reading_date
      expect(temperatures.end_date).to eql reading_2.reading_date
    end

    it 'loads dark sky data, with feature flag set off' do
      reading_1 = create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-01-01')
      reading_2 = create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-02-01')
      ClimateControl.modify FEATURE_FLAG_USE_METEOSTAT: 'false' do
        temperatures = service.temperatures
        expect(temperatures.start_date).to eql reading_1.reading_date
        expect(temperatures.end_date).to eql reading_2.reading_date
      end
    end

    it 'loads meteostat data, with feature flag set on' do
      obs_1 = create(:weather_observation, weather_station: station, reading_date: '2020-01-01')
      obs_2 = create(:weather_observation, weather_station: station, reading_date: '2020-02-01')
      ClimateControl.modify FEATURE_FLAG_USE_METEOSTAT: 'true' do
        temperatures = service.temperatures
        expect(temperatures.start_date).to eql obs_1.reading_date
        expect(temperatures.end_date).to eql obs_2.reading_date
      end
    end

    it 'merges across sources where available' do
      reading_1 = create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-01-01')
      reading_2 = create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-02-01')
      obs_1 = create(:weather_observation, weather_station: station, reading_date: '2020-01-01')
      obs_2 = create(:weather_observation, weather_station: station, reading_date: '2020-02-01')
      ClimateControl.modify FEATURE_FLAG_USE_METEOSTAT: 'true' do
        temperatures = service.temperatures
        #all 4 dates with expected start/end
        expect(temperatures.date_exists?(reading_1.reading_date)).to eql true
        expect(temperatures.date_exists?(reading_2.reading_date)).to eql true
        expect(temperatures.date_exists?(obs_1.reading_date)).to eql true
        expect(temperatures.date_exists?(obs_2.reading_date)).to eql true
        expect(temperatures.start_date).to eql reading_1.reading_date
        expect(temperatures.end_date).to eql obs_2.reading_date
      end
    end

    it 'returns dark sky if no meteostat data' do
      reading_1 = create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-01-01')
      reading_2 = create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-02-01')
      ClimateControl.modify FEATURE_FLAG_USE_METEOSTAT: 'true' do
        temperatures = service.temperatures
        expect(temperatures.date_exists?(reading_1.reading_date)).to eql true
        expect(temperatures.date_exists?(reading_2.reading_date)).to eql true
        expect(temperatures.start_date).to eql reading_1.reading_date
        expect(temperatures.end_date).to eql reading_2.reading_date
      end
    end

    it 'merges across sources where available but returns temperature data only within the date ranges of a schools meter readings' do
      reading_1 = create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-01-01')
      reading_2 = create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-02-01')
      reading_3 = create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-03-01')
      reading_4 = create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-04-01')

      obs_1 = create(:weather_observation, weather_station: station, reading_date: '2020-01-01')
      obs_2 = create(:weather_observation, weather_station: station, reading_date: '2020-02-01')
      obs_3 = create(:weather_observation, weather_station: station, reading_date: '2020-03-01')
      obs_4 = create(:weather_observation, weather_station: station, reading_date: '2020-04-01')

      allow(school).to receive(:reading_date_bounds).and_return([Date.parse('2019-03-01'), Date.parse('2020-02-01')])

      ClimateControl.modify FEATURE_FLAG_USE_METEOSTAT: 'true' do
        temperatures = service.temperatures
        #all 4 dates with expected start/end
        expect(temperatures.date_exists?(reading_1.reading_date)).to eql false
        expect(temperatures.date_exists?(reading_2.reading_date)).to eql false
        expect(temperatures.date_exists?(reading_3.reading_date)).to eql true
        expect(temperatures.date_exists?(reading_4.reading_date)).to eql true


        expect(temperatures.date_exists?(obs_1.reading_date)).to eql true
        expect(temperatures.date_exists?(obs_2.reading_date)).to eql true
        expect(temperatures.date_exists?(obs_3.reading_date)).to eql false
        expect(temperatures.date_exists?(obs_4.reading_date)).to eql false

        expect(temperatures.start_date).to eql reading_3.reading_date
        expect(temperatures.end_date).to eql obs_2.reading_date
      end
    end
  end
end
