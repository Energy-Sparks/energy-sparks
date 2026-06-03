class AreaNames
  def self.key_from_name(name)
    AREA_NAMES.each do |key, area_data|
      return key if name.downcase.include?(key.to_s)
    end
    nil
  end

  def self.check_valid_area(area)
    AREA_NAMES.each_value do |area_data|
      return true if area_data[:name] == name
    end
  end

  def self.temperature_filename(key)
    AREA_NAMES[key][:temperature_filename]
  end

  def self.solar_irradiance_filename(key)
    AREA_NAMES[key][:solar_ir_filename]
  end

  def self.solar_pv_filename(key)
    AREA_NAMES[key][:solar_pv_filename]
  end

  def self.holiday_schedule_filename(key)
    AREA_NAMES[key][:holiday_calendar]
  end

  def self.yahoo_location_name(key)
    AREA_NAMES[key][:yahoo_weather_forecast_id]
  end

  def self.met_office_weather_station_id(key)
    AREA_NAMES[key][:met_office_forecast_id]
  end

  def self.latitude_longitude(key)
    [AREA_NAMES[key][:latitude] , AREA_NAMES[key][:longitude]]
  end

  AREA_NAMES = { # mapping from areas to csv data files for analytics non-db code
    sheffield: {
      name:                       'Sheffield',
      temperature_filename:       'Sheffield temperaturedata.csv',
      solar_ir_filename:          'Sheffield solardata.csv',
      solar_pv_filename:          'pv data Sheffield.csv',
      holiday_calendar:           'Sheffield holidays.csv',
      frontend_darksky_csv_file:  '12-Dark Sky Temperature readings.csv',
      yahoo_weather_forecast_id:  'sheffield, uk', # untested 16Jan2019 post withdrawal of free API
      met_office_forecast_id:     353467,
      latitude:                   53.3811,
      longitude:                  -1.4701
    },
    frome: {
      name:                       'Frome',
      temperature_filename:       'Frome temperaturedata.csv',
      solar_ir_filename:          'Frome solardata.csv',
      solar_pv_filename:          'pv data Frome.csv',
      holiday_calendar:           'Holidays.csv',
      frontend_darksky_csv_file:  '13-Dark Sky Temperature readings.csv',
      yahoo_weather_forecast_id:  'frome, uk', # untested 16Jan2019 post withdrawal of free API
      met_office_forecast_id:     351523,
      latitude:                   51.2308,
      longitude:                  -2.3201
    },
    abingdon: {
      name:                       'Abingdon',
      temperature_filename:       'Abingdon temperaturedata.csv',
      solar_ir_filename:          'Abingdon solardata.csv',
      solar_pv_filename:          'pv data Abingdon.csv',
      holiday_calendar:           'Abingdon holidays.csv',
      frontend_darksky_csv_file:  '14-Dark Sky Temperature readings.csv',
      yahoo_weather_forecast_id:  'abingdon, uk', # untested 20Oct2019 post withdrawal of free API
      met_office_forecast_id:     0,
      latitude:                   51.67,
      longitude:                  -1.285
    },
    highlands: {
      name:                       'Highlands (Inverness)',
      temperature_filename:       'Highlands temperaturedata.csv',
      solar_ir_filename:          'Highlands solardata.csv',
      solar_pv_filename:          'pv data Highlands.csv',
      holiday_calendar:           'Highlands holidays.csv',
      frontend_darksky_csv_file:  '18-Dark Sky Temperature readings.csv',
      yahoo_weather_forecast_id:  'inverness, uk', # untested 16Jan2019 post withdrawal of free API
      met_office_forecast_id:     0,
      latitude:                   57.565289,
      longitude:                  -4.4325656
    },
    bath: {
      name:                       'Bath',
      temperature_filename:       'Bath temperaturedata.csv',
      solar_ir_filename:          'Bath solardata.csv',
      solar_pv_filename:          'pv data Bath.csv',
      holiday_calendar:           'Bath holidays.csv',
      frontend_darksky_csv_file:  '11-Dark Sky Temperature readings.csv',
      yahoo_weather_forecast_id:  'bath, uk',
      met_office_forecast_id:     310026,
      latitude:                   51.3751,
      longitude:                  -2.36172
    },
    wimbledon: {
      name:                       'Wimbledon',
      temperature_filename:       'Wimbledon temperaturedata.csv',
      solar_ir_filename:          'Wimbledon solardata.csv',
      solar_pv_filename:          'pv data Wimbledon.csv',
      holiday_calendar:           'Wimbledon holidays.csv',
      frontend_darksky_csv_file:  '20-Dark Sky Temperature readings.csv',
      yahoo_weather_forecast_id:  'wimbledon, uk',
      met_office_forecast_id:     310026,
      latitude:                   51.42246,
      longitude:                  -0.21085
    },
    portsmouth: {
      name:                       'Portsmouth',
      temperature_filename:       'Portsmouth temperaturedata.csv',
      solar_ir_filename:          'Portsmouth solardata.csv',
      solar_pv_filename:          'pv data Portsmouth.csv',
      holiday_calendar:           'Portsmouth holidays.csv',
      frontend_darksky_csv_file:  '22-Dark Sky Temperature readings.csv',
      yahoo_weather_forecast_id:  'portsmouth, uk',
      met_office_forecast_id:     310026,
      latitude:                   50.819767,
      longitude:                  -1.087977
    },
    east_sussex: {
      name:                       'East Sussex',
      temperature_filename:       'East Sussex temperaturedata.csv',
      solar_ir_filename:          'East Sussex solardata.csv',
      solar_pv_filename:          'pv data East Sussex.csv',
      holiday_calendar:           'East Sussex holidays.csv',
      frontend_darksky_csv_file:  '24-Dark Sky Temperature readings.csv',
      yahoo_weather_forecast_id:  'brighton, uk',
      met_office_forecast_id:     310026,
      latitude:                   50.882553,
      longitude:                  0.104356
    },
    durham: {
      name:                       'Durham',
      temperature_filename:       'Durham temperaturedata.csv',
      solar_ir_filename:          'Durham solardata.csv',
      solar_pv_filename:          'pv data Durham.csv',
      holiday_calendar:           'Holidays.csv',
      frontend_darksky_csv_file:  '26-Dark Sky Temperature readings.csv',
      yahoo_weather_forecast_id:  'durham, uk', # untested 16Jan2019 post withdrawal of free API
      met_office_forecast_id:     351523,
      latitude:                   54.772793,
      longitude:                  -1.576673
    },
    pembroke: {
      name:                       'Pembroke',
      temperature_filename:       'Pembroke temperaturedata.csv',
      solar_ir_filename:          'Pembroke solardata.csv',
      solar_pv_filename:          'pv data Pembroke.csv',
      holiday_calendar:           'Holidays.csv',
      frontend_darksky_csv_file:  '28-Dark Sky Temperature readings.csv',
      yahoo_weather_forecast_id:  'pembroke, uk', # untested 16Jan2019 post withdrawal of free API
      met_office_forecast_id:     310004,
      latitude:                   51.808615,
      longitude:                  -4.976258
    },
  }
end
