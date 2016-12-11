# == Schema Information
#
# Table name: meters
#
#  active     :boolean          default(TRUE)
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  meter_no   :integer
#  meter_type :integer
#  name       :string
#  school_id  :integer
#  updated_at :datetime         not null
#
# Indexes
#
#  index_meters_on_meter_no    (meter_no)
#  index_meters_on_meter_type  (meter_type)
#  index_meters_on_school_id   (school_id)
#
# Foreign Keys
#
#  fk_rails_d7c2c5413f  (school_id => schools.id)
#

class Meter < ApplicationRecord
  belongs_to :school, inverse_of: :meters
  has_many :meter_readings, inverse_of: :meter, dependent: :destroy

  enum meter_type: [:electricity, :gas]
  validates_presence_of :school, :meter_no, :meter_type

  def latest_reading
    meter_readings.order('read_at DESC').limit(1).first
  end

  def last_read
    reading = latest_reading
    reading.present? ? reading.read_at : nil
  end
end
