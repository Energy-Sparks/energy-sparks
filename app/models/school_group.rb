# == Schema Information
#
# Table name: school_groups
#
#  admin_meter_statuses_electricity_id      :bigint(8)
#  admin_meter_statuses_gas_id              :bigint(8)
#  admin_meter_statuses_solar_pv_id         :bigint(8)
#  created_at                               :datetime         not null
#  default_chart_preference                 :integer          default("default"), not null
#  default_country                          :integer          default("england"), not null
#  default_dark_sky_area_id                 :bigint(8)
#  default_data_source_electricity_id       :bigint(8)
#  default_data_source_gas_id               :bigint(8)
#  default_data_source_solar_pv_id          :bigint(8)
#  default_issues_admin_user_id             :bigint(8)
#  default_procurement_route_electricity_id :bigint(8)
#  default_procurement_route_gas_id         :bigint(8)
#  default_procurement_route_solar_pv_id    :bigint(8)
#  default_scoreboard_id                    :bigint(8)
#  default_solar_pv_tuos_area_id            :bigint(8)
#  default_template_calendar_id             :bigint(8)
#  default_weather_station_id               :bigint(8)
#  description                              :string
#  id                                       :bigint(8)        not null, primary key
#  name                                     :string           not null
#  public                                   :boolean          default(TRUE)
#  slug                                     :string           not null
#  updated_at                               :datetime         not null
#
# Indexes
#
#  index_school_groups_on_default_issues_admin_user_id   (default_issues_admin_user_id)
#  index_school_groups_on_default_scoreboard_id          (default_scoreboard_id)
#  index_school_groups_on_default_solar_pv_tuos_area_id  (default_solar_pv_tuos_area_id)
#  index_school_groups_on_default_template_calendar_id   (default_template_calendar_id)
#
# Foreign Keys
#
#  fk_rails_...  (default_issues_admin_user_id => users.id) ON DELETE => nullify
#  fk_rails_...  (default_scoreboard_id => scoreboards.id)
#  fk_rails_...  (default_solar_pv_tuos_area_id => areas.id)
#  fk_rails_...  (default_template_calendar_id => calendars.id) ON DELETE => nullify
#

class SchoolGroup < ApplicationRecord
  extend FriendlyId
  include ParentMeterAttributeHolder
  include Scorable

  friendly_id :name, use: [:finders, :slugged, :history]

  has_many :schools
  has_many :meters, through: :schools
  has_many :school_onboardings
  has_many :calendars, through: :schools
  has_many :users

  has_many :school_group_partners, -> { order(position: :asc) }
  has_many :partners, through: :school_group_partners
  accepts_nested_attributes_for :school_group_partners, reject_if: proc {|attributes| attributes['position'].blank?}

  has_one :dashboard_message, as: :messageable, dependent: :destroy
  has_many :issues, as: :issueable, dependent: :destroy
  has_many :school_issues, through: :schools, source: :issues

  belongs_to :default_template_calendar, class_name: 'Calendar', optional: true
  belongs_to :default_solar_pv_tuos_area, class_name: 'SolarPvTuosArea', optional: true
  belongs_to :default_dark_sky_area, class_name: 'DarkSkyArea', optional: true
  belongs_to :default_weather_station, class_name: 'WeatherStation', foreign_key: 'default_weather_station_id', optional: true
  belongs_to :default_scoreboard, class_name: 'Scoreboard', optional: true
  belongs_to :default_issues_admin_user, class_name: 'User', foreign_key: 'default_issues_admin_user_id', optional: true
  belongs_to :admin_meter_status_electricity, class_name: 'AdminMeterStatus', foreign_key: 'admin_meter_statuses_electricity_id', optional: true
  belongs_to :admin_meter_status_gas, class_name: 'AdminMeterStatus', foreign_key: 'admin_meter_statuses_gas_id', optional: true
  belongs_to :admin_meter_status_solar_pv, class_name: 'AdminMeterStatus', foreign_key: 'admin_meter_statuses_solar_pv_id', optional: true
  belongs_to :default_data_source_electricity, class_name: 'DataSource', foreign_key: 'default_data_source_electricity_id', optional: true
  belongs_to :default_data_source_gas, class_name: 'DataSource', foreign_key: 'default_data_source_gas_id', optional: true
  belongs_to :default_data_source_solar_pv, class_name: 'DataSource', foreign_key: 'default_data_source_solar_pv_id', optional: true
  belongs_to :default_procurement_route_electricity, class_name: 'ProcurementRoute', foreign_key: 'default_procurement_route_electricity_id', optional: true
  belongs_to :default_procurement_route_gas, class_name: 'ProcurementRoute', foreign_key: 'default_procurement_route_gas_id', optional: true
  belongs_to :default_procurement_route_solar_pv, class_name: 'ProcurementRoute', foreign_key: 'default_procurement_route_solar_pv_id', optional: true

  has_many :meter_attributes, inverse_of: :school_group, class_name: 'SchoolGroupMeterAttribute'

  scope :by_name, -> { order(name: :asc) }
  scope :is_public, -> { where(public: true) }
  validates :name, presence: true

  enum default_chart_preference: [:default, :carbon, :usage, :cost]
  enum default_country: School.countries

  def fuel_types
    query = <<-SQL.squish
      SELECT DISTINCT(fuel_types.key) FROM (
        SELECT
          row_to_json(json_each(fuel_configuration))->>'key' as key,
          (row_to_json(json_each(fuel_configuration))->>'value') as value
        FROM configurations
        WHERE school_id IN (#{schools.visible.pluck(:id).join(',')})
      ) as fuel_types
      WHERE fuel_types.value = 'true';
    SQL
    sanitized_query = ActiveRecord::Base.sanitize_sql_array(query)
    SchoolGroup.connection.select_all(sanitized_query).rows.flatten.map { |fuel_type| fuel_type.gsub('has_', '').to_sym }
  end

  def has_visible_schools?
    schools.visible.any?
  end

  def has_schools_awaiting_activation?
    schools.awaiting_activation.any?
  end

  def safe_to_destroy?
    !(schools.any? || users.any?)
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

  def self.with_active_schools
    joins(:schools).where('schools.active = true').distinct
  end

  def all_issues
    Issue.for_school_group(self)
  end

  def email_locales
    default_country == 'wales' ? [:en, :cy] : [:en]
  end

  private

  def this_academic_year
    default_template_calendar&.academic_year_for(Time.zone.today)
  end
end
