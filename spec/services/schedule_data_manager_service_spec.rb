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

  describe '#use_date_bounded_schedule_data?' do
    let!(:school) { create(:school, calendar: calendar) }
    it 'returns false' do
      ClimateControl.modify FEATURE_FLAG_DATE_BOUND_SCHEDULE_DATA: 'false' do
        allow(school).to receive(:minimum_reading_date).and_return(Date.today)
        expect(ScheduleDataManagerService.new(school, :validated_meter_data).send(:use_date_bounded_schedule_data?)).to eq(false)
        allow(school).to receive(:minimum_reading_date).and_return(nil)
        expect(ScheduleDataManagerService.new(school, :validated_meter_data).send(:use_date_bounded_schedule_data?)).to eq(false)
        allow(school).to receive(:minimum_reading_date).and_return(nil)
        expect(ScheduleDataManagerService.new(school, :unvalidated_meter_data).send(:use_date_bounded_schedule_data?)).to eq(false)
      end
      ClimateControl.modify FEATURE_FLAG_DATE_BOUND_SCHEDULE_DATA: 'true' do
        expect(EnergySparks::FeatureFlags.active?(:date_bound_schedule_data)).to eq(true)
        allow(school).to receive(:minimum_reading_date).and_return(nil)
        expect(ScheduleDataManagerService.new(school, :validated_meter_data).send(:use_date_bounded_schedule_data?)).to eq(false)
        allow(school).to receive(:minimum_reading_date).and_return(nil)
        expect(ScheduleDataManagerService.new(school, :unvalidated_meter_data).send(:use_date_bounded_schedule_data?)).to eq(false)
      end
    end

    it 'returns true' do
      ClimateControl.modify FEATURE_FLAG_DATE_BOUND_SCHEDULE_DATA: 'true' do
        expect(EnergySparks::FeatureFlags.active?(:date_bound_schedule_data)).to eq(true)
        allow(school).to receive(:minimum_reading_date).and_return(Date.today)
        expect(ScheduleDataManagerService.new(school, :validated_meter_data).send(:use_date_bounded_schedule_data?)).to eq(true)
      end
    end
  end

  describe '#holidays' do
    let!(:school)                                    { create(:school, calendar: calendar) }
    let(:date_version_of_holiday_date_from_calendar) { Date.parse(random_before_holiday_start_date) }
    let!(:service)                                   { ScheduleDataManagerService.new(school, :validated_meter_data) }

    it 'assigns school date periods for the analytics code' do
      ClimateControl.modify FEATURE_FLAG_DATE_BOUND_SCHEDULE_DATA: 'true' do
        allow(school).to receive(:minimum_reading_date).and_return(nil)
        results = ScheduleDataManagerService.new(school).holidays
        school_date_period = results.find_holiday(date_version_of_holiday_date_from_calendar)
        expect(school_date_period.start_date).to eq date_version_of_holiday_date_from_calendar
        expect(school_date_period.type).to_not be_nil
        expect(results.class).to eq(Holidays)
      end
    end

    it 'loads holiday data' do
      ClimateControl.modify FEATURE_FLAG_DATE_BOUND_SCHEDULE_DATA: 'true' do
        results = service.holidays
        expect(results.holidays.map { |holiday| [holiday.start_date, holiday.end_date].sort }).to eq([
                                                                                                       [Date.parse('01-01-2017'), Date.parse('01-02-2017')],
                                                                                                       [Date.parse('21-10-2017'), Date.parse('29-10-2017')],
                                                                                                       [Date.parse('16-12-2017'), Date.parse('20-12-2017')]
                                                                                                     ])
        expect(results.class).to eq(Holidays)
      end
    end

    it 'loads all holiday data even if date bounds of school meter data is set' do
      ClimateControl.modify FEATURE_FLAG_DATE_BOUND_SCHEDULE_DATA: 'true' do
        allow(school).to receive(:minimum_reading_date).and_return(Date.parse('2017-06-01'))

        results = service.holidays
        expect(results.holidays.map { |holiday| [holiday.start_date, holiday.end_date].sort }).to eq([
                                                                                                       [Date.parse('01-01-2017'), Date.parse('01-02-2017')],
                                                                                                       [Date.parse('21-10-2017'), Date.parse('29-10-2017')],
                                                                                                       [Date.parse('16-12-2017'), Date.parse('20-12-2017')]
                                                                                                     ])
        expect(results.class).to eq(Holidays)
      end
    end
  end

  describe '#uk_grid_carbon_intensity' do
    let!(:school)           { create(:school, solar_pv_tuos_area: create(:solar_pv_tuos_area)) }
    let!(:service)          { ScheduleDataManagerService.new(school, :validated_meter_data) }

    it 'loads the uk grid carbon intensity data' do
      ClimateControl.modify FEATURE_FLAG_DATE_BOUND_SCHEDULE_DATA: 'true' do
        reading_1 = create(:carbon_intensity_reading, reading_date: Date.parse('2019-01-01'))
        reading_2 = create(:carbon_intensity_reading, reading_date: Date.parse('2019-02-01'))
        reading_3 = create(:carbon_intensity_reading, reading_date: Date.parse('2019-03-01'))
        reading_4 = create(:carbon_intensity_reading, reading_date: Date.parse('2019-04-01'))
        reading_5 = create(:carbon_intensity_reading, reading_date: Date.parse('2019-05-01'))

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

    it 'loads the uk grid carbon intensity data but returns data only within the date ranges of a schools meter readings' do
      ClimateControl.modify FEATURE_FLAG_DATE_BOUND_SCHEDULE_DATA: 'true' do
        reading_1 = create(:carbon_intensity_reading, reading_date: Date.parse('2019-01-01'))
        reading_2 = create(:carbon_intensity_reading, reading_date: Date.parse('2019-02-01'))
        reading_3 = create(:carbon_intensity_reading, reading_date: Date.parse('2019-03-01'))
        reading_4 = create(:carbon_intensity_reading, reading_date: Date.parse('2019-04-01'))
        reading_5 = create(:carbon_intensity_reading, reading_date: Date.parse('2019-05-01'))

        allow(school).to receive(:minimum_reading_date).and_return(Date.parse('2019-02-01'))
        uk_grid_carbon_intensity = service.uk_grid_carbon_intensity

        expect(uk_grid_carbon_intensity.keys.sort).to eq([Date.parse('2019-02-01'), Date.parse('2019-03-01'), Date.parse('2019-04-01'), Date.parse('2019-05-01')])
        expect(uk_grid_carbon_intensity.class).to eq(GridCarbonIntensity)
      end
    end
  end

  describe '#solar_pv' do
    let!(:school)           { create(:school, solar_pv_tuos_area: create(:solar_pv_tuos_area)) }
    let!(:service)          { ScheduleDataManagerService.new(school, :validated_meter_data) }
    it 'loads the solar pv data' do
      ClimateControl.modify FEATURE_FLAG_DATE_BOUND_SCHEDULE_DATA: 'true' do
        reading_1 = create(:solar_pv_tuos_reading, area_id: school.solar_pv_tuos_area.id, reading_date: '2019-01-01')
        reading_2 = create(:solar_pv_tuos_reading, area_id: school.solar_pv_tuos_area.id, reading_date: '2019-02-01')
        reading_3 = create(:solar_pv_tuos_reading, area_id: school.solar_pv_tuos_area.id, reading_date: '2019-03-01')
        reading_4 = create(:solar_pv_tuos_reading, area_id: school.solar_pv_tuos_area.id, reading_date: '2019-04-01')
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

    it 'loads the solar pv data but returns solar pv data only within the date ranges of a schools meter readings' do
      ClimateControl.modify FEATURE_FLAG_DATE_BOUND_SCHEDULE_DATA: 'true' do
        reading_1 = create(:solar_pv_tuos_reading, area_id: school.solar_pv_tuos_area.id, reading_date: Date.parse('2019-01-01'))
        reading_2 = create(:solar_pv_tuos_reading, area_id: school.solar_pv_tuos_area.id, reading_date: '2019-02-01')
        reading_3 = create(:solar_pv_tuos_reading, area_id: school.solar_pv_tuos_area.id, reading_date: '2019-03-01')
        reading_4 = create(:solar_pv_tuos_reading, area_id: school.solar_pv_tuos_area.id, reading_date: '2019-04-01')
        reading_5 = create(:solar_pv_tuos_reading, area_id: school.solar_pv_tuos_area.id, reading_date: '2019-05-01')
        allow(school).to receive(:minimum_reading_date).and_return(Date.parse('2019-03-01'))
        solar_pv = service.solar_pv
        expect(solar_pv.start_date).to eql reading_3.reading_date
        expect(solar_pv.end_date).to eql reading_5.reading_date
        expect(solar_pv.keys.sort).to eq(
          [
            Date.parse('2019-03-01'),
            Date.parse('2019-04-01'),
            Date.parse('2019-05-01')
          ]
        )
        expect(solar_pv.class).to eq(SolarPV)
      end
    end
  end

  describe '#temperatures' do
    let!(:area)             { create(:dark_sky_area) }
    let!(:station)          { create(:weather_station) }
    let!(:school)           { create(:school, dark_sky_area: area, weather_station: station) }

    let!(:service)          { ScheduleDataManagerService.new(school, :validated_meter_data) }

    before { allow(school).to receive(:minimum_reading_date).and_return(nil) }

    it 'loads dark_sky data' do
      reading_1 = create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-01-01')
      reading_2 = create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-02-01')
      ClimateControl.modify FEATURE_FLAG_DATE_BOUND_SCHEDULE_DATA: 'true' do
        temperatures = service.temperatures

        expect(temperatures.start_date).to eql reading_1.reading_date
        expect(temperatures.end_date).to eql reading_2.reading_date
        expect(temperatures.class).to eq(Temperatures)
      end
    end

    it 'loads dark sky data, with feature flag set off' do
      reading_1 = create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-01-01')
      reading_2 = create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-02-01')
      ClimateControl.modify FEATURE_FLAG_USE_METEOSTAT: 'false', FEATURE_FLAG_DATE_BOUND_SCHEDULE_DATA: 'true' do
        temperatures = service.temperatures
        expect(temperatures.start_date).to eql reading_1.reading_date
        expect(temperatures.end_date).to eql reading_2.reading_date
        expect(temperatures.class).to eq(Temperatures)
      end
    end

    it 'loads meteostat data, with feature flag set on' do
      obs_1 = create(:weather_observation, weather_station: station, reading_date: '2020-01-01')
      obs_2 = create(:weather_observation, weather_station: station, reading_date: '2020-02-01')
      ClimateControl.modify FEATURE_FLAG_USE_METEOSTAT: 'true', FEATURE_FLAG_DATE_BOUND_SCHEDULE_DATA: 'true' do
        temperatures = service.temperatures
        expect(temperatures.start_date).to eql obs_1.reading_date
        expect(temperatures.end_date).to eql obs_2.reading_date
        expect(temperatures.class).to eq(Temperatures)
      end
    end

    it 'merges across sources where available' do
      reading_1 = create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-01-01')
      reading_2 = create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-02-01')
      obs_1 = create(:weather_observation, weather_station: station, reading_date: '2020-01-01')
      obs_2 = create(:weather_observation, weather_station: station, reading_date: '2020-02-01')
      ClimateControl.modify FEATURE_FLAG_USE_METEOSTAT: 'true', FEATURE_FLAG_DATE_BOUND_SCHEDULE_DATA: 'true' do
        temperatures = service.temperatures
        #all 4 dates with expected start/end
        expect(temperatures.date_exists?(reading_1.reading_date)).to eql true
        expect(temperatures.date_exists?(reading_2.reading_date)).to eql true
        expect(temperatures.date_exists?(obs_1.reading_date)).to eql true
        expect(temperatures.date_exists?(obs_2.reading_date)).to eql true
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

    it 'returns dark sky if no meteostat data' do
      reading_1 = create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-01-01')
      reading_2 = create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-02-01')
      ClimateControl.modify FEATURE_FLAG_USE_METEOSTAT: 'true', FEATURE_FLAG_DATE_BOUND_SCHEDULE_DATA: 'true' do
        temperatures = service.temperatures
        expect(temperatures.date_exists?(reading_1.reading_date)).to eql true
        expect(temperatures.date_exists?(reading_2.reading_date)).to eql true
        expect(temperatures.start_date).to eql reading_1.reading_date
        expect(temperatures.end_date).to eql reading_2.reading_date
        expect(temperatures.class).to eq(Temperatures)
      end
    end

    it 'merges across sources where available but returns temperature data only within the date ranges of a schools meter readings' do
      reading_1 = create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2017-01-01')
      reading_2 = create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2018-01-01')
      reading_3 = create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-01-01')
      reading_4 = create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-02-01')
      reading_5 = create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-03-01')
      reading_6 = create(:dark_sky_temperature_reading, dark_sky_area: area, reading_date: '2019-04-01')
      obs_1 = create(:weather_observation, weather_station: station, reading_date: '2020-01-01')
      obs_2 = create(:weather_observation, weather_station: station, reading_date: '2020-02-01')
      obs_3 = create(:weather_observation, weather_station: station, reading_date: '2020-03-01')
      obs_4 = create(:weather_observation, weather_station: station, reading_date: '2020-04-01')
      allow(school).to receive(:minimum_reading_date).and_return(Date.parse('2019-03-01'))
      ClimateControl.modify FEATURE_FLAG_USE_METEOSTAT: 'true', FEATURE_FLAG_DATE_BOUND_SCHEDULE_DATA: 'true' do
        temperatures = service.temperatures
        #all 4 dates with expected start/end
        expect(temperatures.date_exists?(reading_1.reading_date)).to eql false
        expect(temperatures.date_exists?(reading_2.reading_date)).to eql false
        expect(temperatures.date_exists?(reading_3.reading_date)).to eql true
        expect(temperatures.date_exists?(reading_4.reading_date)).to eql true
        expect(temperatures.date_exists?(reading_5.reading_date)).to eql true
        expect(temperatures.date_exists?(reading_6.reading_date)).to eql true
        expect(temperatures.date_exists?(obs_1.reading_date)).to eql true
        expect(temperatures.date_exists?(obs_2.reading_date)).to eql true
        expect(temperatures.date_exists?(obs_3.reading_date)).to eql true
        expect(temperatures.date_exists?(obs_4.reading_date)).to eql true
        expect(temperatures.start_date).to eql reading_3.reading_date
        expect(temperatures.end_date).to eql obs_4.reading_date
        expect(temperatures.keys.sort).to eq(
          [
            Date.parse('2019-01-01'),
            Date.parse('2019-02-01'),
            Date.parse('2019-03-01'),
            Date.parse('2019-04-01'),
            Date.parse('2020-01-01'),
            Date.parse('2020-02-01'),
            Date.parse('2020-03-01'),
            Date.parse('2020-04-01')
          ]
        )
        expect(temperatures.class).to eq(Temperatures)
      end
    end
  end
end
