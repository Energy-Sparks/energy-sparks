# == Schema Information
#
# Table name: meters
#
#  active                         :boolean          default(TRUE)
#  consent_granted                :boolean          default(FALSE)
#  created_at                     :datetime         not null
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
#  pseudo                         :boolean          default(FALSE)
#  rtone_variant_installation_id  :bigint(8)
#  sandbox                        :boolean          default(FALSE)
#  school_id                      :bigint(8)        not null
#  solar_edge_installation_id     :bigint(8)
#  updated_at                     :datetime         not null
#
# Indexes
#
#  index_meters_on_low_carbon_hub_installation_id  (low_carbon_hub_installation_id)
#  index_meters_on_meter_review_id                 (meter_review_id)
#  index_meters_on_meter_type                      (meter_type)
#  index_meters_on_mpan_mprn                       (mpan_mprn) UNIQUE
#  index_meters_on_rtone_variant_installation_id   (rtone_variant_installation_id)
#  index_meters_on_school_id                       (school_id)
#  index_meters_on_solar_edge_installation_id      (solar_edge_installation_id)
#
# Foreign Keys
#
#  fk_rails_...  (low_carbon_hub_installation_id => low_carbon_hub_installations.id) ON DELETE => cascade
#  fk_rails_...  (meter_review_id => meter_reviews.id)
#  fk_rails_...  (rtone_variant_installation_id => rtone_variant_installations.id)
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#  fk_rails_...  (solar_edge_installation_id => solar_edge_installations.id) ON DELETE => cascade
#

class Meter < ApplicationRecord
  belongs_to :school, inverse_of: :meters
  belongs_to :low_carbon_hub_installation, optional: true
  belongs_to :solar_edge_installation, optional: true
  has_one :rtone_variant_installation, required: false

  has_many :amr_data_feed_readings,     inverse_of: :meter, dependent: :destroy
  has_many :amr_validated_readings,     inverse_of: :meter, dependent: :destroy

  has_many :tariff_prices,              inverse_of: :meter
  has_many :tariff_standing_charges,    inverse_of: :meter

  has_many :meter_attributes

  belongs_to :meter_review, optional: true
  has_and_belongs_to_many :user_tariffs, inverse_of: :meters

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

  scope :unreviewed_dcc_meter, -> { where(dcc_meter: true, consent_granted: false, meter_review: nil) }
  scope :awaiting_trusted_consent, -> { where(dcc_meter: true, consent_granted: false).where.not(meter_review: nil) }
  scope :dcc, -> { where(dcc_meter: true) }
  scope :consented, -> { where(dcc_meter: true, consent_granted: true) }

  # If adding a new one, add to the amr_validated_reading case statement for downloading data
  enum meter_type: [:electricity, :gas, :solar_pv, :exported_solar_pv]

  delegate :area_name, to: :school

  validates_presence_of :school, :mpan_mprn, :meter_type
  validates_uniqueness_of :mpan_mprn

  validates_format_of :mpan_mprn, with: /\A[6,7,9]\d{13}\Z/, if: :pseudo?, message: 'for pseudo electricity meters should be a 14 digit number starting with 6, 7 or 9'
  validates_format_of :mpan_mprn, with: /\A[1-9]{1,3}\d{12}\Z/, if: :real_electric?, message: 'for electricity meters should be a 13 to 14 digit number'
  validates_format_of :mpan_mprn, with: /\A\d{1,15}\Z/, if: :gas?, message: 'for gas meters should be a 1-15 digit number'

  def self.hash_of_meter_data
    meter_data_array = Meter.pluck(:mpan_mprn, :meter_type, :school_id)
    meter_data_array.to_h { |record| [record[0].to_s, { fuel_type: record[1], school_id: record[2] }]}
  end

  def school_name
    school.name
  end

  def fuel_type
    meter_type.to_sym
  end

  def self.non_gas_meter_types
    Meter.meter_types.keys - ['gas']
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
    gaps = amr_validated_readings.since(since_date).by_date.chunk_while { |r1, r2| r1.modified && r2.modified }
    # return chunks of specified size or bigger
    gaps.select { |gap| gap.count >= gap_size }
  end

  def display_name
    name.present? ? "#{display_meter_mpan_mprn} (#{name})" : display_meter_mpan_mprn
  end

  def display_meter_mpan_mprn
    "#{mpan_mprn} - #{meter_type.to_s.humanize}"
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

  def user_tariff_meter_attributes
    user_tariffs.map(&:meter_attribute)
  end

  def all_meter_attributes
    global_meter_attributes + school_group_meter_attributes + school_meter_attributes + meter_attributes.active + user_tariff_meter_attributes
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

  private

  def real_electric?
    !gas? && !pseudo?
  end
end
