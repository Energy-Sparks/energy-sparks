# == Schema Information
#
# Table name: amr_validated_readings
#
#  id              :bigint(8)        not null, primary key
#  kwh_data_x48    :decimal(, )      not null, is an Array
#  meter_id        :bigint(8)        not null
#  one_day_kwh     :decimal(, )      not null
#  reading_date    :date             not null
#  status          :text             not null
#  substitute_date :date
#  upload_datetime :datetime
#
# Indexes
#
#  index_amr_validated_readings_on_meter_id  (meter_id)
#  unique_amr_meter_validated_readings       (meter_id,reading_date) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (meter_id => meters.id)
#

class AmrValidatedReading < ApplicationRecord
  belongs_to :meter, inverse_of: :amr_validated_readings
end
