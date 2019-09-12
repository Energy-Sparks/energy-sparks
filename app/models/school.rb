# == Schema Information
#
# Table name: schools
#
#  active                                :boolean          default(FALSE)
#  address                               :text
#  calendar_area_id                      :bigint(8)
#  calendar_id                           :bigint(8)
#  cooks_dinners_for_other_schools       :boolean          default(FALSE), not null
#  cooks_dinners_for_other_schools_count :integer
#  cooks_dinners_onsite                  :boolean          default(FALSE), not null
#  created_at                            :datetime         not null
#  dark_sky_area_id                      :bigint(8)
#  floor_area                            :decimal(, )
#  has_solar_panels                      :boolean          default(FALSE), not null
#  has_swimming_pool                     :boolean          default(FALSE), not null
#  id                                    :bigint(8)        not null, primary key
#  level                                 :integer          default(0)
#  met_office_area_id                    :bigint(8)
#  name                                  :string
#  number_of_pupils                      :integer
#  postcode                              :string
#  school_group_id                       :bigint(8)
#  school_type                           :integer
#  serves_dinners                        :boolean          default(FALSE), not null
#  slug                                  :string
#  solar_irradiance_area_id              :bigint(8)
#  solar_pv_tuos_area_id                 :bigint(8)
#  temperature_area_id                   :bigint(8)
#  template_calendar_id                  :integer
#  updated_at                            :datetime         not null
#  urn                                   :integer          not null
#  weather_underground_area_id           :bigint(8)
#  website                               :string
#
# Indexes
#
#  index_schools_on_calendar_id      (calendar_id)
#  index_schools_on_school_group_id  (school_group_id)
#  index_schools_on_urn              (urn) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (calendar_area_id => calendar_areas.id) ON DELETE => restrict
#  fk_rails_...  (calendar_id => calendars.id)
#  fk_rails_...  (school_group_id => school_groups.id)
#

class School < ApplicationRecord
  include AmrUsage
  extend FriendlyId
  friendly_id :slug_candidates, use: [:finders, :slugged, :history]

  delegate :holiday_approaching?, :next_holiday, to: :calendar

  has_and_belongs_to_many :key_stages, join_table: :school_key_stages

  has_many :users,                dependent: :destroy
  has_many :meters,               inverse_of: :school, dependent: :destroy
  has_many :school_times,         inverse_of: :school, dependent: :destroy
  has_many :activities,           inverse_of: :school, dependent: :destroy
  has_many :contacts,             inverse_of: :school, dependent: :destroy
  has_many :observations,         inverse_of: :school, dependent: :destroy

  has_many :programmes,               inverse_of: :school, dependent: :destroy
  has_many :programme_activity_types, through: :programmes, source: :activity_types

  has_many :alerts,                  inverse_of: :school, dependent: :destroy
  has_many :content_generation_runs, inverse_of: :school

  has_many :equivalences

  has_many :locations

  has_many :simulations, inverse_of: :school, dependent: :destroy

  has_many :amr_data_feed_readings,       through: :meters
  has_many :amr_validated_readings,       through: :meters
  has_many :alert_subscription_events,    through: :contacts

  belongs_to :calendar, optional: true
  belongs_to :template_calendar, optional: true, class_name: 'Calendar'
  belongs_to :calendar_area, optional: true
  belongs_to :solar_pv_tuos_area, optional: true
  belongs_to :dark_sky_area, optional: true
  belongs_to :school_group, optional: true

  has_one :school_onboarding
  has_one :configuration, class_name: 'Schools::Configuration'

  enum school_type: [:primary, :secondary, :special, :infant, :junior, :middle]

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :without_group, -> { where(school_group_id: nil) }

  validates_presence_of :urn, :name, :address, :postcode, :website
  validates_uniqueness_of :urn
  validates :floor_area, :number_of_pupils, :cooks_dinners_for_other_schools_count, numericality: { greater_than: 0, allow_blank: true }
  validates :cooks_dinners_for_other_schools_count, presence: true, if: :cooks_dinners_for_other_schools?

  validates_associated :school_times, on: :school_time_update

  accepts_nested_attributes_for :school_times

  auto_strip_attributes :name, :website, :postcode, squish: true

  def should_generate_new_friendly_id?
    slug.blank? || name_changed? || postcode_changed?
  end

  # Prevent the generated urls from becoming too long
  def normalize_friendly_id(string)
    super[0..59]
  end

  # Try building a slug based on the following fields in increasing order of specificity.
  def slug_candidates
    [
      :name,
      [:postcode, :name],
      [:urn, :name]
    ]
  end

  def area_name
    school_group.name if school_group
  end

  def active_meters
    meters.where(active: true)
  end

  def meters_for_supply(supply)
    meters.where(meter_type: supply)
  end

  def meters?(supply = nil)
    meters_for_supply(supply).any?
  end

  def meters_with_readings(supply = Meter.meter_types.keys)
    meters.includes(:amr_data_feed_readings).where(meter_type: supply).where.not(amr_data_feed_readings: { meter_id: nil })
  end

  def meters_with_validated_readings(supply = Meter.meter_types.keys)
    meters.includes(:amr_validated_readings).where(meter_type: supply).where.not(amr_validated_readings: { meter_id: nil })
  end

  def both_supplies?
    meters_with_readings(:electricity).any? && meters_with_readings(:gas).any?
  end

  def fuel_types
    if both_supplies?
      :electric_and_gas
    elsif meters_with_readings(:electricity).any?
      :electric_only
    elsif meters_with_readings(:gas).any?
      :gas_only
    else
      :none
    end
  end

  def has_gas?
    configuration.gas
  end

  def has_electricity?
    configuration.electricity
  end

  def analysis?
    configuration && configuration.analysis_charts.present?
  end

  def fuel_types_for_analysis
    Schools::GenerateFuelConfiguration.new(self).generate.fuel_types_for_analysis
  end

  def has_solar_pv?
    meters.detect(&:solar_pv?)
  end

  def has_storage_heaters?
    meters.detect(&:storage_heaters?)
  end

  def current_term
    calendar.terms.find_by('NOW()::DATE BETWEEN start_date AND end_date')
  end

  def last_term
    calendar.terms.find_by('end_date <= ?', current_term.start_date)
  end

  def number_of_active_meters
    meters.where(active: true).count
  end

  def expected_readings_for_a_week
    7 * number_of_active_meters
  end

  def has_last_full_week_of_readings?
    previous_friday = Time.zone.today.prev_occurring(:friday)

    start_of_window = previous_friday - 1.week
    end_of_window = previous_friday
    actual_readings = amr_validated_readings.where('reading_date > ? and reading_date <= ?', start_of_window, end_of_window).count

    actual_readings == expected_readings_for_a_week
  end

  def school_admin
    users.where(role: :school_admin)
  end

  def scoreboard
    school_group.scoreboard if school_group
  end

  def latest_content
    content_generation_runs.order(created_at: :desc).first
  end

  def latest_dashboard_alerts
    if latest_content
      latest_content.dashboard_alerts
    else
      DashboardAlert.none
    end
  end
end
