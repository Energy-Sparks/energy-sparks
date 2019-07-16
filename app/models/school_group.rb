# frozen_string_literal: true

# == Schema Information
#
# Table name: school_groups
#
#  created_at                          :datetime         not null
#  default_calendar_area_id            :bigint(8)
#  default_dark_sky_area_id            :bigint(8)
#  default_solar_pv_tuos_area_id       :bigint(8)
#  default_weather_underground_area_id :bigint(8)
#  description                         :string
#  id                                  :bigint(8)        not null, primary key
#  name                                :string           not null
#  scoreboard_id                       :bigint(8)
#  slug                                :string           not null
#  updated_at                          :datetime         not null
#
# Indexes
#
#  index_school_groups_on_default_calendar_area_id             (default_calendar_area_id)
#  index_school_groups_on_default_solar_pv_tuos_area_id        (default_solar_pv_tuos_area_id)
#  index_school_groups_on_default_weather_underground_area_id  (default_weather_underground_area_id)
#  index_school_groups_on_scoreboard_id                        (scoreboard_id)
#
# Foreign Keys
#
#  fk_rails_...  (default_calendar_area_id => areas.id)
#  fk_rails_...  (default_solar_pv_tuos_area_id => areas.id)
#  fk_rails_...  (default_weather_underground_area_id => areas.id)
#  fk_rails_...  (scoreboard_id => scoreboards.id)
#

class SchoolGroup < ApplicationRecord
  extend FriendlyId

  friendly_id :name, use: [:finders, :slugged, :history]

  has_many :schools
  belongs_to :scoreboard

  belongs_to :default_calendar_area, class_name: 'CalendarArea'
  belongs_to :default_solar_pv_tuos_area, class_name: 'SolarPvTuosArea'
  belongs_to :default_weather_underground_area, class_name: 'WeatherUndergroundArea'
  belongs_to :default_dark_sky_area, class_name: 'DarkSkyArea'

  validates :name, presence: true

  def safe_destroy
    raise EnergySparks::SafeDestroyError, 'Group has associated schools' if schools.any?
    destroy
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end
end
