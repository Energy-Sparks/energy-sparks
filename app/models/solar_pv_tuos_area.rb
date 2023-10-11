# == Schema Information
#
# Table name: areas
#
#  active          :boolean          default(TRUE)
#  back_fill_years :integer          default(4)
#  description     :text
#  gsp_id          :integer
#  gsp_name        :string
#  id              :bigint(8)        not null, primary key
#  latitude        :decimal(10, 6)
#  longitude       :decimal(10, 6)
#  title           :text
#  type            :text             not null
#

# TUOS is The University of Sheffield
class SolarPvTuosArea < Area
  has_many :solar_pv_tuos_readings, class_name: 'DataFeeds::SolarPvTuosReading', foreign_key: :area_id, dependent: :destroy
  has_many :schools, inverse_of: :solar_pv_tuos_area

  # reinstate once we've finished tidying up areas
  # validates_uniqueness_of :gsp_id

  validates :latitude, :longitude, :title, :back_fill_years, :gsp_name, presence: true
  validate :cannot_be_inactive_if_attached_to_schools

  def reading_count
    solar_pv_tuos_readings.count
  end

  def has_sufficient_readings?(latest_date, minimum_readings_per_year)
    solar_pv_tuos_readings.since(latest_date - back_fill_years.years).count >= minimum_readings_per_year * back_fill_years
  end

  def first_reading_date
    solar_pv_tuos_readings.by_date.first.reading_date.strftime('%d %b %Y') if reading_count > 0
  end

  def last_reading_date
    solar_pv_tuos_readings.by_date.last.reading_date.strftime('%d %b %Y') if reading_count > 0
  end

  def cannot_be_inactive_if_attached_to_schools
    errors.add(:active, 'cannot disable region as it is used by some schools') if !active && schools.count > 0
  end
end
