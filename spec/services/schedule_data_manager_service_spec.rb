require 'rails_helper'

describe ScheduleDataManagerService do
  include_context 'calendar data'

  describe '#calendar_cache_key' do
    let!(:school) { create(:school, calendar: calendar) }

    it 'generates a key' do
      expect(ScheduleDataManagerService.calendar_cache_key(calendar)).to include(calendar.id.to_s)
    end
  end

  describe '#invalidate_cached_calendar' do
    let!(:school) { create(:school, calendar: calendar) }

    it 'invalidates cache' do
      expect(Rails.cache).to receive(:delete)
      ScheduleDataManagerService.invalidate_cached_calendar(calendar)
    end
  end

  describe '#holidays' do
    let!(:school)                                    { create(:school, calendar: calendar) }
    let(:date_version_of_holiday_date_from_calendar) { Date.parse(random_before_holiday_start_date) }
    let!(:service)                                   { ScheduleDataManagerService.new(school) }

    it 'assigns school date periods for the analytics code' do
      results = ScheduleDataManagerService.new(school).holidays
      school_date_period = results.find_holiday(date_version_of_holiday_date_from_calendar)
      expect(school_date_period.start_date).to eq date_version_of_holiday_date_from_calendar
      expect(school_date_period.type).not_to be_nil
      expect(results.class).to eq(Holidays)
    end

    it 'loads holiday data' do
      results = service.holidays
      expect(results.holidays.map { |holiday| [holiday.start_date, holiday.end_date].sort }).to eq([
                                                                                                     [Date.parse('01-01-2017'), Date.parse('01-02-2017')],
                                                                                                     [Date.parse('21-10-2017'), Date.parse('29-10-2017')],
                                                                                                     [Date.parse('16-12-2017'), Date.parse('20-12-2017')]
                                                                                                   ])
      expect(results.class).to eq(Holidays)
    end
  end

  describe '#uk_grid_carbon_intensity' do
    let!(:school)           { create(:school, solar_pv_tuos_area: create(:solar_pv_tuos_area)) }
    let!(:service)          { ScheduleDataManagerService.new(school) }

    it 'loads the uk grid carbon intensity data' do
      create(:carbon_intensity_reading, reading_date: Date.parse('2019-01-01'))
      create(:carbon_intensity_reading, reading_date: Date.parse('2019-02-01'))
      create(:carbon_intensity_reading, reading_date: Date.parse('2019-03-01'))
      create(:carbon_intensity_reading, reading_date: Date.parse('2019-04-01'))
      create(:carbon_intensity_reading, reading_date: Date.parse('2019-05-01'))

      allow(school).to receive(:minimum_reading_date).and_return(nil)
      uk_grid_carbon_intensity = service.uk_grid_carbon_intensity

      # uk_grid_carbon_intensity is a Hash
      expect(uk_grid_carbon_intensity.keys.sort).to eq(
        [
          Date.parse('2019-01-01'),
          Date.parse('2019-02-01'),
          Date.parse('2019-03-01'),
          Date.parse('2019-04-01'),
          Date.parse('2019-05-01')
        ]
      )
      expect(uk_grid_carbon_intensity.class).to eq(GridCarbonIntensity)
    end
  end

  describe '#solar_pv' do
    let!(:school)           { create(:school, solar_pv_tuos_area: create(:solar_pv_tuos_area)) }
    let!(:service)          { ScheduleDataManagerService.new(school) }

    it 'loads the solar pv data' do
      reading_1 = create(:solar_pv_tuos_reading, area_id: school.solar_pv_tuos_area.id, reading_date: '2019-01-01')
      create(:solar_pv_tuos_reading, area_id: school.solar_pv_tuos_area.id, reading_date: '2019-02-01')
      create(:solar_pv_tuos_reading, area_id: school.solar_pv_tuos_area.id, reading_date: '2019-03-01')
      create(:solar_pv_tuos_reading, area_id: school.solar_pv_tuos_area.id, reading_date: '2019-04-01')
      reading_5 = create(:solar_pv_tuos_reading, area_id: school.solar_pv_tuos_area.id, reading_date: '2019-05-01')
      allow(school).to receive(:minimum_reading_date).and_return(nil)
      solar_pv = service.solar_pv
      expect(solar_pv.start_date).to eql reading_1.reading_date
      expect(solar_pv.end_date).to eql reading_5.reading_date
      expect(solar_pv.keys.sort).to eq(
        [
          Date.parse('2019-01-01'),
          Date.parse('2019-02-01'),
          Date.parse('2019-03-01'),
          Date.parse('2019-04-01'),
          Date.parse('2019-05-01')
        ]
      )
      expect(solar_pv.class).to eq(SolarPV)
    end
  end

  describe '#temperatures' do
    let!(:area)             { create(:dark_sky_area) }
    let!(:station)          { create(:weather_station) }
    let!(:school)           { create(:school, dark_sky_area: area, weather_station: station) }

    let!(:service)          { ScheduleDataManagerService.new(school) }

    before { allow(school).to receive(:minimum_reading_date).and_return(nil) }

    it 'loads dark_sky data' do
      reading_1 = create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-01-01')
      reading_2 = create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-02-01')
      temperatures = service.temperatures
      expect(temperatures.start_date).to eql reading_1.reading_date
      expect(temperatures.end_date).to eql reading_2.reading_date
      expect(temperatures.class).to eq(Temperatures)
    end

    it 'loads meteostat data, with feature flag set on' do
      obs_1 = create(:weather_observation, weather_station: station, reading_date: '2020-01-01')
      obs_2 = create(:weather_observation, weather_station: station, reading_date: '2020-02-01')
      temperatures = service.temperatures
      expect(temperatures.start_date).to eql obs_1.reading_date
      expect(temperatures.end_date).to eql obs_2.reading_date
      expect(temperatures.class).to eq(Temperatures)
    end

    it 'merges across sources where available' do
      reading_1 = create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-01-01')
      reading_2 = create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-02-01')
      obs_1 = create(:weather_observation, weather_station: station, reading_date: '2020-01-01')
      obs_2 = create(:weather_observation, weather_station: station, reading_date: '2020-02-01')
      temperatures = service.temperatures
      #all 4 dates with expected start/end
      expect(temperatures.date_exists?(reading_1.reading_date)).to be true
      expect(temperatures.date_exists?(reading_2.reading_date)).to be true
      expect(temperatures.date_exists?(obs_1.reading_date)).to be true
      expect(temperatures.date_exists?(obs_2.reading_date)).to be true
      expect(temperatures.start_date).to eql reading_1.reading_date
      expect(temperatures.end_date).to eql obs_2.reading_date

      expect(temperatures.keys.sort).to eq(
        [
          Date.parse('2019-01-01'),
          Date.parse('2019-02-01'),
          Date.parse('2020-01-01'),
          Date.parse('2020-02-01')
        ]
      )
      expect(temperatures.class).to eq(Temperatures)
    end
  end
end
