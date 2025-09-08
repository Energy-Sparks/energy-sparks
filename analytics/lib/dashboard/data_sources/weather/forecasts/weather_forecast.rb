# wrapper around a weather forecast download
# over the years free APIs have come and gone: yahoo, accu and/or
# reduced their functionality: met office data point
# forecast come back in differing formats, so try to separate
# out the data provided from the applications use of it
# currently caches requests on an approx 30km grid
class WeatherForecast
  attr_reader :forecast, :latitude, :longitude, :date

  def self.nearest_cached_forecast_factory(asof_date, latitude, longitude)
    get_live_forecast(asof_date, latitude, longitude)
  end

  def start_date
    @forecast.keys.first
  end

  def end_date
    @forecast.keys.last
  end

  def average_temperature_within_hours(date, start_hour, end_hour)
    average_data_within_hours(date, start_hour,  end_hour, :temperature)
  end

  def average_cloud_cover_within_hours(date, start_hour, end_hour)
    average_data_within_hours(date, start_hour,  end_hour, :cloud_cover)
  end

  def average_data_within_hours(date, start_hour, end_hour, type)
    data = @forecast[date].select { |d| d[:time_of_day].hour.between?(start_hour, end_hour) }
    data.empty? ? nil : data.map { |d| d[type] }.sum / data.length
  end

  def self.truncated_forecast(weather, date)
    WeatherForecast.new(weather.forecast.select { |d, _f| d <= date })
  end

  def self.artificial_forecast(config)
    forecast_temperatures = (config[:start_date]..config[:end_date]).map do |date|
      [
        date,
        (0..47).step(4).map do |hh_i|
          {
            time_of_day: TimeOfDay.time_of_day_from_halfhour_index(hh_i),
            temperature: config[:temperature]
          }
        end
      ]
    end.to_h

    WeatherForecast.new(forecast_temperatures, config[:start_date], 0.0, 0.0)
  end

  private

  def initialize(forecast, date, latitude, longitude)
    @forecast   = forecast
    @date       = date
    @latitude   = latitude
    @longitude  = longitude
  end

  # monkey patched to pickup artificial forecast in test environment
  private_class_method def self.get_live_forecast(asof_date, latitude, longitude)
    f = WeatherForecastCache.instance.cached_forecast(asof_date, latitude, longitude)
    WeatherForecast.new(f, asof_date, latitude, longitude)
  end
end

class WeatherForecastCache
  include Logging
  include Singleton
  MIN_CACHE_DISTANCE_KM=30
  LONGITUDE_GRID=0.35 # approx 30km longitude, > for latitude

  def cached_forecast(asof_date, latitude, longitude)
    lat, long = round_latitude_longitude_to_grid(latitude, longitude)
    cache(asof_date)[cache_key(lat, long)] || download_cached_forecast(asof_date, lat, long)
  end

  private

  def round_latitude_longitude_to_grid(latitude, longitude)
    [round_to_grid(latitude), round_to_grid(longitude)]
  end

  def round_to_grid(coordinate_1)
    ((coordinate_1 / LONGITUDE_GRID).round(0) * LONGITUDE_GRID).round(2)
  end

  def cache_key(latitude, longitude)
    {latitude: latitude, longitude: longitude}
  end

  def download_cached_forecast(asof_date, latitude, longitude)
    add_cache(asof_date, latitude, longitude, download_forecast(latitude, longitude))
  end

  def add_cache(asof_date, latitude, longitude, forecast_data)
    # monkey patched in test environment to speedup, save API requests
    # asof_date not used in live environment
    cache(asof_date)[cache_key(latitude, longitude)] = forecast_data
  end

  def cache(asof_date)
    # monkey patched in test environment to speedup, save API requests
    # asof_date not used in live environment
    @cache ||= Hash.new { |hash, key| hash[key] = {} }

    @cache[asof_date]
  end

  def download_forecast(latitude, longitude)
    logger.info "Downloading a forecast for #{latitude} #{longitude}"
    VisualCrossingWeatherForecast.new.forecast(latitude, longitude)
  end
end
