# == Schema Information
#
# Table name: meters
#
#  active              :boolean          default(TRUE)
#  created_at          :datetime         not null
#  floor_area          :decimal(, )
#  id                  :bigint(8)        not null, primary key
#  meter_no            :bigint(8)
#  meter_serial_number :text
#  meter_type          :integer
#  mpan_mprn           :bigint(8)
#  name                :string
#  number_of_pupils    :integer
#  school_id           :bigint(8)
#  solar_pv            :boolean          default(FALSE)
#  storage_heaters     :boolean          default(FALSE)
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_meters_on_meter_no    (meter_no)
#  index_meters_on_meter_type  (meter_type)
#  index_meters_on_school_id   (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id)
#

class Meter < ApplicationRecord
  belongs_to :school, inverse_of: :meters
  has_many :meter_readings,             inverse_of: :meter, dependent: :destroy
  has_many :aggregated_meter_readings,  inverse_of: :meter, dependent: :destroy
  has_many :amr_data_feed_readings,     inverse_of: :meter, dependent: :destroy

  scope :active,   -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  enum meter_type: [:electricity, :gas]
  validates_presence_of :school, :meter_no, :meter_type
  validates_uniqueness_of :meter_no

  # TODO integrate this analytics
  attr_accessor :amr_data, :floor_area, :number_of_pupils, :storage_heater_config, :solar_pv_installation
  attr_writer :sub_meters, :meter_correction_rules

  def to_s
    "#{mpan_mprn} : #{meter_type} x #{@amr_data.nil? ? '0' : amr_data.length}"
  end

  # There is some ambiguity in the analysis code between what is a collection of meters
  # and what is a school or building
  # TODO fix
  def meter_collection
    school
  end

  def sub_meters
    @sub_meters ||= []
  end

  def fuel_type
    meter_type.to_sym
  end

  def any_aggregated?
    aggregated_meter_readings.any?
  end

  def first_reading
    meter_readings.order('read_at ASC').limit(1).first
  end

  def first_read
    reading = first_reading
    reading.present? ? reading.read_at : nil
  end

  def latest_reading
    meter_readings.order('read_at DESC').limit(1).first
  end

  def last_read
    reading = latest_reading
    reading.present? ? reading.read_at : nil
  end

  def display_name
    name.present? ? "#{meter_no} (#{name})" : display_meter_number
  end

  def display_meter_number
    meter_no.present? ? meter_no : meter_type.to_s
  end

  def add_correction_rule(rule)
    throw EnergySparksUnexpectedStateException.new('Unexpected nil correction') if rule.nil?
    meter_correction_rules.push(rule)
  end

  def insert_correction_rules_first(rules)
    meter_correction_rules.concat(rules)
  end

  #TODO Temp from load from amr code
  def meter_correction_rules
    if meter_type == 'gas' && @meter_correction_rules.nil?
      @meter_correction_rules = [{ auto_insert_missing_readings: { type: :weekends } }]
    elsif @meter_correction_rules.nil?
      []
    else
      @meter_correction_rules
    end
  end

  def safe_destroy
    raise EnergySparks::SafeDestroyError, 'Meter has associated readings' if meter_readings.any? || amr_data_feed_readings.any?
    destroy
  end
end
