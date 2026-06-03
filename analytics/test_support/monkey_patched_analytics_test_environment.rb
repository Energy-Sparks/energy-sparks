# override main analytics library functions specifically
# for where test only benchmarking and calibration
# code is being used, a dangerous approach but it
# has been required by the front end developers, it runs
# the risk of the analytics testing  different code
# than used in the front end; so great care needs to
# be taken with its use
class WeatherForecastCache
  private

  def add_cache(asof_date, latitude, longitude, forecast_data)
    cache(asof_date)[cache_key(latitude, longitude)] = forecast_data
    # a little inefficient as will save ~30/multiple times on 1st batch run
    file_writer(asof_date).save(cache(asof_date))
    forecast_data
  end

  def cache(asof_date)
    @cache ||= Hash.new { |hash, key| hash[key] = {} }

    if @cache[asof_date].empty? && file_writer(asof_date).exists?
      @cache[asof_date] = file_writer(asof_date).load
    end

    @cache[asof_date]
  end

  def filename_stub(asof_date)
    File.join(TestDirectory.instance.test_directory_name('CacheData'), "weatherforecastcache #{asof_date}")
  end

  def file_writer(asof_date)
    FileWriter.new(filename_stub(asof_date))
  end
end

class WeatherForecast
  private_class_method def self.get_live_forecast(asof_date, latitude, longitude)
    if ENV['ENERGYSPARKSFORECAST'].nil?
      f = WeatherForecastCache.instance.cached_forecast(asof_date, latitude, longitude)
      WeatherForecast.new(f, asof_date, latitude, longitude)
    else
      artificial_forecast(YAML.load(ENV['ENERGYSPARKSFORECAST']))
    end
  end
end

class LatitudeLongitude
  def self.schools_latitude_longitude(school)
    @@latlong_cache ||= {}
    @@latlong_cache = writer.load if @@latlong_cache.empty? && writer.exists?

    return @@latlong_cache[school.postcode] if @@latlong_cache.key?(school.postcode)

    @@latlong_cache[school.postcode] = schools_latitude_longitude_private(school)

    writer.save(@@latlong_cache)
    @@latlong_cache[school.postcode]
  end

  private

  def self.writer
    FileWriter.new(filename)
  end

  def self.filename
    File.join(TestDirectory.instance.test_directory_name('CacheData'), "postcode lat long cache")
  end
end
