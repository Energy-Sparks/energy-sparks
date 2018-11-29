# == Schema Information
#
# Table name: schools
#
#  active                      :boolean          default(FALSE)
#  address                     :text
#  calendar_area_id            :bigint(8)
#  calendar_id                 :bigint(8)
#  created_at                  :datetime         not null
#  floor_area                  :decimal(, )
#  id                          :bigint(8)        not null, primary key
#  level                       :integer          default(0)
#  met_office_area_id          :bigint(8)
#  name                        :string
#  number_of_pupils            :integer
#  postcode                    :string
#  sash_id                     :bigint(8)
#  school_group_id             :bigint(8)
#  school_type                 :integer
#  slug                        :string
#  solar_irradiance_area_id    :bigint(8)
#  solar_pv_tuos_area_id       :bigint(8)
#  temperature_area_id         :bigint(8)
#  updated_at                  :datetime         not null
#  urn                         :integer          not null
#  weather_underground_area_id :bigint(8)
#  website                     :string
#
# Indexes
#
#  index_schools_on_calendar_id      (calendar_id)
#  index_schools_on_sash_id          (sash_id)
#  index_schools_on_school_group_id  (school_group_id)
#  index_schools_on_urn              (urn) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (calendar_id => calendars.id)
#  fk_rails_...  (school_group_id => school_groups.id)
#

class School < ApplicationRecord
  include AmrUsage
  extend FriendlyId
  friendly_id :slug_candidates, use: [:finders, :slugged, :history]

  delegate :holiday_approaching?, to: :calendar

  include Merit::UsageCalculations
  has_merit

  acts_as_taggable_on :key_stages

  has_many :users, dependent: :destroy
  has_many :meters, inverse_of: :school, dependent: :destroy

  has_many :amr_data_feed_readings, through: :meters
  has_many :amr_validated_readings, through: :meters

  has_many :activities, inverse_of: :school, dependent: :destroy
  has_many :school_times, inverse_of: :school, dependent: :destroy
  has_many :contacts,     inverse_of: :school, dependent: :destroy
  has_many :alerts,       inverse_of: :school, dependent: :destroy
  has_many :simulations, inverse_of: :school, dependent: :destroy

  belongs_to :calendar
  belongs_to :calendar_area
  belongs_to :weather_underground_area
  belongs_to :solar_pv_tuos_area
  belongs_to :school_group

  enum school_type: [:primary, :secondary, :special, :infant, :junior, :middle]

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :without_group, -> { where(school_group_id: nil) }

  validates_presence_of :urn, :name
  validates_uniqueness_of :urn

  validates_associated :school_times, on: :school_time_update

  accepts_nested_attributes_for :school_times

  after_create :create_sash_relation

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
    school_group.name
  end

  # TODO: This is not performant and requires some rework or re-architecturing
  # Analytics code will use it's own version in the meantime

  # def is_open?(datetime)
  #   time = datetime.to_time.utc
  #   return false if time.saturday? || time.sunday?
  #   day_of_week = time.strftime("%A").downcase
  #   school_time = school_times.find_by(day: day_of_week)
  #   time_as_number = datetime.hour * 100 + datetime.min
  #   school_time.opening_time < time_as_number && school_time.closing_time > time_as_number
  # end

  # TODO integrate this analytics
  def heat_meters
    active_meters.where(meter_type: :gas)
  end

  def electricity_meters
    active_meters.where(meter_type: :electricity)
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

  def meters_with_readings(supply = nil)
    meters.includes(:amr_data_feed_readings).where(meter_type: supply).where.not(amr_data_feed_readings: { meter_id: nil })
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

  def has_badge?(id)
    sash.badge_ids.include?(id)
  end

  def alerts?
    alerts.any?
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

    start_of_window = previous_friday.end_of_day - 1.week
    end_of_window = previous_friday.end_of_day
    actual_readings = amr_data_feed_readings.where('reading_date >= ? and reading_date <= ?', start_of_window, end_of_window).count
    actual_readings == expected_readings_for_a_week
  end

  def badges_by_date(order: :desc, limit: nil)
    sash.badges_sashes.order(created_at: order)
      .limit(limit)
      .map(&:badge)
  end

  def points_since(since = 1.month.ago)
    self.score_points.where("created_at > '#{since}'").sum(:num_points)
  end

  def school_admin
    users.where(role: :school_admin)
  end

  def scoreboard
    school_group.scoreboard if school_group
  end

  def self.top_scored(dates: nil, limit: nil)
    if dates.present?
      start_date = dates.first.beginning_of_day
      end_date = dates.last.end_of_day
    else
      # If no dates are present grab points since the beginning of the academic year
      september = Time.current.beginning_of_month.change(month: 9)
      start_date = september.future? ? september.last_year : september
      end_date = Time.current
    end

    School.select('schools.*, SUM(num_points) AS sum_points')
      .joins('left join merit_scores ON merit_scores.sash_id = schools.sash_id')
      .joins('left join merit_score_points ON merit_score_points.score_id = merit_scores.id')
      .where('merit_score_points.created_at BETWEEN ? AND ?', start_date, end_date)
      .order('sum_points DESC')
      .group('schools.id, merit_scores.sash_id')
      .limit(limit)
  end

private

  # Create Merit::Sash relation
  # Having the sash relation makes life easier elsewhere
  def create_sash_relation
    badges
  end
end
