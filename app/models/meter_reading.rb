# == Schema Information
#
# Table name: meter_readings
#
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  meter_id   :integer
#  read_at    :datetime
#  unit       :string
#  updated_at :datetime         not null
#  value      :decimal(, )
#
# Indexes
#
#  index_meter_readings_on_meter_id  (meter_id)
#  index_meter_readings_on_read_at   (read_at)
#
# Foreign Keys
#
#  fk_rails_457104cd53  (meter_id => meters.id)
#

class MeterReading < ApplicationRecord
  belongs_to :meter
end
