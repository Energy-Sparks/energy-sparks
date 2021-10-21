# == Schema Information
#
# Table name: school_groups
#
#  created_at                    :datetime         not null
#  default_dark_sky_area_id      :bigint(8)
#  default_scoreboard_id         :bigint(8)
#  default_solar_pv_tuos_area_id :bigint(8)
#  default_template_calendar_id  :bigint(8)
#  default_weather_station_id    :bigint(8)
#  description                   :string
#  id                            :bigint(8)        not null, primary key
#  name                          :string           not null
#  public                        :boolean          default(TRUE)
#  slug                          :string           not null
#  updated_at                    :datetime         not null
#
# Indexes
#
#  index_school_groups_on_default_scoreboard_id          (default_scoreboard_id)
#  index_school_groups_on_default_solar_pv_tuos_area_id  (default_solar_pv_tuos_area_id)
#  index_school_groups_on_default_template_calendar_id   (default_template_calendar_id)
#
# Foreign Keys
#
#  fk_rails_...  (default_scoreboard_id => scoreboards.id)
#  fk_rails_...  (default_solar_pv_tuos_area_id => areas.id)
#  fk_rails_...  (default_template_calendar_id => calendars.id) ON DELETE => nullify
#

class SchoolGroup < ApplicationRecord
  extend FriendlyId
  include ParentMeterAttributeHolder

  friendly_id :name, use: [:finders, :slugged, :history]

  has_many :schools
  has_many :school_onboardings
  has_many :calendars, through: :schools
  has_many :users

  has_many :school_group_partners, -> { order(position: :asc) }
  has_many :partners, through: :school_group_partners
  accepts_nested_attributes_for :school_group_partners, reject_if: proc {|attributes| attributes['position'].blank?}

  belongs_to :default_template_calendar, class_name: 'Calendar', optional: true
  belongs_to :default_solar_pv_tuos_area, class_name: 'SolarPvTuosArea', optional: true
  belongs_to :default_dark_sky_area, class_name: 'DarkSkyArea', optional: true
  belongs_to :default_weather_station, class_name: 'WeatherStation', foreign_key: 'default_weather_station_id', optional: true
  belongs_to :default_scoreboard, class_name: 'Scoreboard', optional: true

  has_many :meter_attributes, inverse_of: :school_group, class_name: 'SchoolGroupMeterAttribute'

  scope :by_name, -> { order(name: :asc) }
  scope :is_public, -> { where(public: true) }
  validates :name, presence: true

  def has_visible_schools?
    schools.visible.any?
  end

  def has_schools_awaiting_activation?
    schools.not_visible.any?
  end

  def safe_destroy
    raise EnergySparks::SafeDestroyError, 'Group has associated schools' if schools.any?
    raise EnergySparks::SafeDestroyError, 'Group has associated users' if users.any?
    destroy
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def update_school_partner_positions!(position_attributes)
    transaction do
      school_group_partners.destroy_all
      update!(school_group_partners_attributes: position_attributes)
    end
  end

  def page_anchor
    name.parameterize
  end
end
