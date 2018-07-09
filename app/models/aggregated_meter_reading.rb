# == Schema Information
#
# Table name: aggregated_meter_readings
#
#  id         :bigint(8)        not null, primary key
#  meter_id   :bigint(8)
#  readings   :decimal(, )      is an Array
#  substitute :boolean          default(FALSE)
#  total      :decimal(, )      default(0.0)
#  unit       :text
#  verified   :boolean          default(FALSE)
#  when       :date             not null
#
# Indexes
#
#  index_aggregated_meter_readings_on_meter_id  (meter_id)
#
# Foreign Keys
#
#  fk_rails_...  (meter_id => meters.id)
#

class AggregatedMeterReading < ApplicationRecord
  belongs_to :meter
end
