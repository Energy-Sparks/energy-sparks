# == Schema Information
#
# Table name: meters
#
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  meter_no   :integer
#  meter_type :integer
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
  belongs_to :school
  has_many :meter_readings, dependent: :destroy

  enum meter_type: [:electricity, :gas]
  validates_presence_of :meter_no, :meter_type
end
