# https://www.visualcrossing.com/weather/weather-data-services
#

class VisualCrossingWeatherForecastRaw
  def initialize(api_key = ENV['VISUALCROSSINGAPIKEY'])
    @api_key = api_key
  end

  def forecast(latitude, longitude)
    url = forecast_url(latitude, longitude)
    uri = URI(url)

    res = Net::HTTP.get_response(uri)

    if res.is_a?(Net::HTTPSuccess)
      JSON.parse(res.body)
    else
      raise HttpError, "status #{res.status} #{res.body}"
    end
  end

  private

  def forecast_url(latitude, longitude)
    services_base + 'timeline/' + location_url_str(latitude, longitude) + '?unitGroup=metric&key=' + @api_key + '&contentType=json'
  end

  def location_url_str(latitude, longitude)
    "#{latitude}%2C#{longitude}"
  end

  def services_base
    'https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/'
  end
end


class VisualCrossingWeatherForecast
  def initialize(api_key = ENV['VISUALCROSSINGAPIKEY'])
    @interface = VisualCrossingWeatherForecastRaw.new(api_key)
  end

  def forecast(latitude, longitude)
    f = @interface.forecast(latitude, longitude)
    f['days'].map do |day|
      [
        Date.parse(day['datetime']),
        convert_whole_day(day)
      ]
    end.to_h.sort.to_h
  end

  def convert_whole_day(day)
    day['hours'].map do |hour|
      if hour['temp'].nil?
        nil
      else
        t = Time.at(hour['datetimeEpoch'])
        {
          time_of_day:  TimeOfDay.new(t.hour, t.min),
          temperature:  hour['temp'],
          cloud_cover:  hour['cloudcover'].to_f / 100.0
        }
      end
    end.compact.sort_by { |h| h[:time_of_day] }
  end
end
