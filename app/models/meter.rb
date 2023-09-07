# == Schema Information
#
# Table name: meters
#
#  active                         :boolean          default(TRUE)
#  admin_meter_statuses_id        :bigint(8)
#  consent_granted                :boolean          default(FALSE)
#  created_at                     :datetime         not null
#  data_source_id                 :bigint(8)
#  dcc_checked_at                 :datetime
#  dcc_meter                      :boolean          default(FALSE)
#  earliest_available_data        :date
#  id                             :bigint(8)        not null, primary key
#  low_carbon_hub_installation_id :bigint(8)
#  meter_review_id                :bigint(8)
#  meter_serial_number            :text
#  meter_type                     :integer
#  mpan_mprn                      :bigint(8)
#  name                           :string
#  procurement_route_id           :bigint(8)
#  pseudo                         :boolean          default(FALSE)
#  sandbox                        :boolean          default(FALSE)
#  school_id                      :bigint(8)        not null
#  solar_edge_installation_id     :bigint(8)
#  updated_at                     :datetime         not null
#
# Indexes
#
#  index_meters_on_data_source_id                  (data_source_id)
#  index_meters_on_low_carbon_hub_installation_id  (low_carbon_hub_installation_id)
#  index_meters_on_meter_review_id                 (meter_review_id)
#  index_meters_on_meter_type                      (meter_type)
#  index_meters_on_mpan_mprn                       (mpan_mprn) UNIQUE
#  index_meters_on_procurement_route_id            (procurement_route_id)
#  index_meters_on_school_id                       (school_id)
#  index_meters_on_solar_edge_installation_id      (solar_edge_installation_id)
#
# Foreign Keys
#
#  fk_rails_...  (low_carbon_hub_installation_id => low_carbon_hub_installations.id) ON DELETE => cascade
#  fk_rails_...  (meter_review_id => meter_reviews.id)
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#  fk_rails_...  (solar_edge_installation_id => solar_edge_installations.id) ON DELETE => cascade
#

class Meter < ApplicationRecord
  belongs_to :school, inverse_of: :meters
  belongs_to :low_carbon_hub_installation, optional: true
  belongs_to :solar_edge_installation, optional: true
  belongs_to :meter_review, optional: true
  belongs_to :data_source, optional: true
  belongs_to :procurement_route, optional: true
  belongs_to :admin_meter_status, foreign_key: 'admin_meter_statuses_id', optional: true

  has_one :rtone_variant_installation, required: false

  has_many :amr_data_feed_readings,     inverse_of: :meter
  has_many :amr_validated_readings,     inverse_of: :meter, dependent: :destroy
  has_many :tariff_prices,              inverse_of: :meter, dependent: :destroy
  has_many :tariff_standing_charges,    inverse_of: :meter, dependent: :destroy
  has_many :meter_attributes
  has_many :issue_meters, dependent: :destroy
  has_many :issues, through: :issue_meters

  has_one :school_group, through: :school
  has_and_belongs_to_many :energy_tariffs, inverse_of: :meters

  CREATABLE_METER_TYPES = [:electricity, :gas, :solar_pv, :exported_solar_pv].freeze
  MAIN_METER_TYPES = [:electricity, :gas].freeze
  SUB_METER_TYPES = [:solar_pv, :exported_solar_pv].freeze

  scope :active,   -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :real, -> { where(pseudo: false) }
  scope :pseudo, -> { where(pseudo: true) }
  scope :main_meter, -> { where(pseudo: false, meter_type: MAIN_METER_TYPES) }
  scope :sub_meter, -> { where(pseudo: true, meter_type: SUB_METER_TYPES) }
  scope :no_amr_validated_readings, -> { left_outer_joins(:amr_validated_readings).where(amr_validated_readings: { meter_id: nil }) }

  scope :unreviewed_dcc_meter, -> { where(dcc_meter: true, consent_granted: false, meter_review_id: nil) }
  scope :reviewed_dcc_meter, -> { where(dcc_meter: true).where.not(meter_review_id: nil) }
  scope :awaiting_trusted_consent, -> { where(dcc_meter: true, consent_granted: false).where.not(meter_review: nil) }
  scope :not_dcc, -> { where(dcc_meter: false) }
  scope :dcc, -> { where(dcc_meter: true) }
  scope :consented, -> { where(dcc_meter: true, consent_granted: true) }
  scope :not_recently_checked, -> { where("dcc_checked_at is NULL OR dcc_checked_at < ?", 2.months.ago) }
  scope :meters_to_check_against_dcc, -> { main_meter.not_dcc.not_recently_checked }
  scope :data_source_known, -> { where.not(data_source: nil) }
  scope :procurement_route_known, -> { where.not(procurement_route: nil) }

  scope :with_zero_reading_days_and_dates, -> {
      left_outer_joins(:amr_validated_readings)
        .group('schools.id', 'meters.id')
        .select(
          "meters.*,
           MIN(amr_validated_readings.reading_date) AS first_validated_reading_date,
           MAX(amr_validated_readings.reading_date) AS last_validated_reading_date,
           COUNT(1) FILTER (WHERE one_day_kwh = 0.0) AS zero_reading_days_count")
  }

  # If adding a new one, add to the amr_validated_reading case statement for downloading data
  enum meter_type: [:electricity, :gas, :solar_pv, :exported_solar_pv]

  delegate :area_name, to: :school

  validates_presence_of :school, :mpan_mprn, :meter_type
  validates_uniqueness_of :mpan_mprn

  validates_format_of :mpan_mprn, with: /\A[6,7,9]\d{13}\Z/, if: :pseudo?, message: 'for pseudo electricity meters should be a 14 digit number starting with 6, 7 or 9'
  validates_format_of :mpan_mprn, with: /\A[1-9]{1,3}\d{12}\Z/, if: :real_electric?, message: 'for electricity meters should be a 13 to 14 digit number'
  validates_format_of :mpan_mprn, with: /\A\d{1,15}\Z/, if: :gas?, message: 'for gas meters should be a 1-15 digit number'
  validate :pseudo_meter_type_not_changed, on: :update, if: :pseudo
  validate :pseudo_mpan_mprn_not_changed, on: :update, if: :pseudo

  def self.hash_of_meter_data
    meter_data_array = Meter.pluck(:mpan_mprn, :meter_type, :school_id)
    meter_data_array.to_h { |record| [record[0].to_s, { fuel_type: record[1], school_id: record[2] }]}
  end

  def school_name
    school.name
  end

  def admin_meter_status_label
    for_fuel_type = (fuel_type == :exported_solar_pv ? :solar_pv : fuel_type)
    admin_meter_status&.label || school&.school_group&.send(:"admin_meter_status_#{for_fuel_type}")&.label || ''
  end

  def fuel_type
    meter_type.to_sym
  end

  def self.non_gas_meter_types
    Meter.meter_types.keys - ['gas']
  end

  def number_of_validated_readings
    last_reading = last_validated_reading
    first_reading = first_validated_reading
    return 0 if last_reading.nil?
    return (last_reading - first_reading).to_i + 1
  end

  def first_validated_reading
    amr_validated_readings.minimum(:reading_date)
  end

  def last_validated_reading
    amr_validated_readings.maximum(:reading_date)
  end

  def modified_validated_readings(years = 2)
    since_date = Time.zone.today - years.years
    amr_validated_readings.since(since_date).modified
  end

  def gappy_validated_readings(gap_size = 14, years = 2)
    since_date = Time.zone.today - years.years
    # only interested if there are enough non_ORIG readings
    return [] unless amr_validated_readings.since(since_date).modified.count >= gap_size
    # find chunks where consecutive readings were all non-ORIG
    gaps = amr_validated_readings.since(since_date).by_date.select(:reading_date, :status).chunk_while { |r1, r2| r1.status != 'ORIG' && r2.status != 'ORIG' }
    # return chunks of specified size or bigger
    gaps.select { |gap| gap.count >= gap_size }
  end

  def zero_reading_days
    amr_validated_readings.where(one_day_kwh: 0)
  end

  def zero_reading_days_warning?
    return true if fuel_type == :electricity && zero_reading_days.any?
  end

  def has_readings?
    amr_validated_readings.any?
  end

  def name_or_mpan_mprn
    name.present? ? name : mpan_mprn.to_s
  end

  def mpan_mprn_and_name
    name.present? ? "#{mpan_mprn} - #{name}" : mpan_mprn
  end

  def display_name
    name.present? ? "#{display_meter_mpan_mprn} (#{name})" : display_meter_mpan_mprn
  end

  def display_meter_mpan_mprn
    "#{mpan_mprn} - #{meter_type.to_s.humanize}"
  end

  def display_summary(display_name: true, display_data_source: true, display_inactive: false)
    output = mpan_mprn.to_s
    output += " - #{name}" if display_name && name.present?
    output += " - #{data_source.name}" if display_data_source && data_source
    output += " (inactive)" if display_inactive && !active?
    output
  end

  def school_meter_attributes
    school.meter_attributes_for(self)
  end

  def school_group_meter_attributes
    school.school_group ? school.school_group.meter_attributes_for(self) : SchoolGroupMeterAttribute.none
  end

  def global_meter_attributes
    GlobalMeterAttribute.for(self)
  end

  def all_meter_attributes
    global_meter_attributes +
      school_group_meter_attributes +
      school_meter_attributes +
      active_meter_attributes +
      energy_tariff_meter_attributes
  end

  def active_meter_attributes
    if EnergySparks::FeatureFlags.active?(:new_energy_tariff_editor)
      meter_attributes.where.not(attribute_type: GlobalMeterAttribute::TARIFF_ATTRIBUTE_TYPES).active
    else
      meter_attributes.active
    end
  end

  def energy_tariff_meter_attributes
    attributes = []
    if EnergySparks::FeatureFlags.active?(:new_energy_tariff_editor)
      school_attributes = school.all_energy_tariff_attributes(meter_type, applies_to_key)
      attributes += school_attributes unless school_attributes.nil?
    end
    attributes += energy_tariffs.enabled.usable.map(&:meter_attribute)
    attributes
  end

  def applies_to_key
    half_hourly ? :half_hourly : :non_half_hourly
  end

  def meter_attributes_to_analytics
    MeterAttribute.to_analytics(all_meter_attributes)
  end

  def correct_mpan_check_digit?
    return true if gas? || pseudo
    mpan = mpan_mprn.to_s.last(13)
    primes = [3, 5, 7, 13, 17, 19, 23, 29, 31, 37, 41, 43]
    expected_check = (0..11).inject(0) { |sum, n| sum + (mpan[n, 1].to_i * primes[n]) } % 11 % 10
    expected_check.to_s == mpan.last
  end

  def can_grant_consent?
    meter_review.present? && !consent_granted
  end

  def can_withdraw_consent?
    consent_granted
  end

  def smart_meter_tariff_attributes
    @smart_meter_tariff_attributes ||= Amr::AnalyticsTariffFactory.new(self).build
  end

  def open_issues_count
    open_issues.count
  end

  def open_issues_as_list
    open_issues.order(created_at: :asc).map { |issue| issue&.description&.body&.to_plain_text }
  end

  def open_issues
    issues&.where(issue_type: "issue")&.status_open
  end

  private

  def pseudo_mpan_mprn_not_changed
    return unless pseudo && mpan_mprn_changed?

    errors.add(:mpan_mprn, "Change of mpan mprn is not allowed for pseudo meters")
  end

  def pseudo_meter_type_not_changed
    return unless pseudo && meter_type_changed?

    errors.add(:meter_type, "Change of meter type is not allowed for pseudo meters")
  end

  def real_electric?
    !gas? && !pseudo?
  end
end
