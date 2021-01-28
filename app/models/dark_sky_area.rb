# == Schema Information
#
# Table name: areas
#
#  back_fill_years :integer          default(4)
#  description     :text
#  id              :bigint(8)        not null, primary key
#  latitude        :decimal(10, 6)
#  longitude       :decimal(10, 6)
#  title           :text
#  type            :text             not null
#
class DarkSkyArea < Area
  has_many :dark_sky_temperature_readings, class_name: 'DataFeeds::DarkSkyTemperatureReading', foreign_key: :area_id, dependent: :destroy

  validates_presence_of :latitude, :longitude, :title, :back_fill_years

  def reading_count
    dark_sky_temperature_readings.count
  end

  def has_sufficient_readings?(latest_date, minimum_readings_per_year)
    dark_sky_temperature_readings.since(latest_date - back_fill_years.years).count >= minimum_readings_per_year * back_fill_years
  end

  def first_reading_date
    if reading_count > 0
      dark_sky_temperature_readings.by_date.first.reading_date.strftime('%d %b %Y')
    end
  end

  def last_reading_date
    if reading_count > 0
      dark_sky_temperature_readings.by_date.last.reading_date.strftime('%d %b %Y')
    end
  end
end
