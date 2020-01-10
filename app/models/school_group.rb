# == Schema Information
#
# Table name: school_groups
#
#  created_at                    :datetime         not null
#  default_dark_sky_area_id      :bigint(8)
#  default_solar_pv_tuos_area_id :bigint(8)
#  default_template_calendar_id  :bigint(8)
#  description                   :string
#  id                            :bigint(8)        not null, primary key
#  name                          :string           not null
#  scoreboard_id                 :bigint(8)
#  slug                          :string           not null
#  updated_at                    :datetime         not null
#
# Indexes
#
#  index_school_groups_on_default_solar_pv_tuos_area_id  (default_solar_pv_tuos_area_id)
#  index_school_groups_on_default_template_calendar_id   (default_template_calendar_id)
#  index_school_groups_on_scoreboard_id                  (scoreboard_id)
#
# Foreign Keys
#
#  fk_rails_...  (default_solar_pv_tuos_area_id => areas.id)
#  fk_rails_...  (default_template_calendar_id => calendars.id) ON DELETE => nullify
#  fk_rails_...  (scoreboard_id => scoreboards.id)
#

class SchoolGroup < ApplicationRecord
  extend FriendlyId
  include ParentMeterAttributeHolder

  friendly_id :name, use: [:finders, :slugged, :history]

  has_many :schools
  has_many :school_onboardings
  has_many :calendars, through: :schools
  has_many :users
  belongs_to :scoreboard, optional: true

  belongs_to :default_template_calendar, class_name: 'Calendar', optional: true
  belongs_to :default_solar_pv_tuos_area, class_name: 'SolarPvTuosArea', optional: true
  belongs_to :default_dark_sky_area, class_name: 'DarkSkyArea', optional: true

  has_many :meter_attributes, inverse_of: :school_group, class_name: 'SchoolGroupMeterAttribute'

  validates :name, presence: true

  def safe_destroy
    raise EnergySparks::SafeDestroyError, 'Group has associated schools' if schools.any?
    raise EnergySparks::SafeDestroyError, 'Group has associated users' if users.any?
    destroy
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end
end
