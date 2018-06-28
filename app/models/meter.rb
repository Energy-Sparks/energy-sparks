# == Schema Information
#
# Table name: meters
#
#  active              :boolean          default(TRUE)
#  created_at          :datetime         not null
#  floor_area          :decimal(, )
#  id                  :integer          not null, primary key
#  meter_no            :bigint(8)
#  meter_serial_number :text
#  meter_type          :integer
#  mpan_mprn           :integer
#  name                :string
#  number_of_pupils    :integer
#  school_id           :integer
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
  has_many :meter_readings, inverse_of: :meter, dependent: :destroy

  enum meter_type: [:electricity, :gas]
  validates_presence_of :school, :meter_no, :meter_type
  validates_uniqueness_of :meter_no

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
    name.present? ? "#{meter_no} (#{name})" : meter_no.to_s
  end
end
