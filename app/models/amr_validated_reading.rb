# == Schema Information
#
# Table name: amr_readings
#
#  date            :date             not null
#  id              :bigint(8)        not null, primary key
#  kwh_data_x48    :decimal(11, 5)   not null, is an Array
#  meter_id        :bigint(8)        not null
#  one_day_kwh     :decimal(11, 5)   not null
#  status          :text             not null
#  substitute_date :date
#  upload_datetime :datetime
#
# Indexes
#
#  index_amr_readings_on_meter_id  (meter_id)
#  unique_amr_meter_readings       (meter_id,one_day_kwh,status,date) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (meter_id => meters.id)
#

require 'upsert'
require 'upsert/active_record_upsert'
require 'upsert/connection/postgresql'
require 'upsert/connection/PG_Connection'
require 'upsert/merge_function/PG_Connection'
require 'upsert/column_definition/postgresql'

class AmrValidatedReading < ApplicationRecord
  belongs_to :meter, inverse_of: :amr_validated_readings

  # Used to create a record from a one day reading
  # def self.create_from_one_day_reading(one_day_reading)

  #   # If it's a substitute value, then it isn't going to know it's meter id - meter_id will
  #   # be set by the analytics code as the meter_no, i.e. MPAN/MPRN
  #   # TODO meter_id needs refactoring in back end analytics code
  #   meter_id = if one_day_reading.type != 'ORIG'
  #                Meter.find_by(meter_no: one_day_reading.meter_id).id
  #              else
  #                one_day_reading.meter_id
  #              end

  #   if meter_id.present?
  #     create(
  #       meter_id: meter_id,
  #       reading_date: one_day_reading.date,
  #       kwh_data_x48: one_day_reading.kwh_data_x48,
  #       one_day_kwh: one_day_reading.one_day_kwh,
  #       substitute_date: one_day_reading.substitute_date,
  #       status: one_day_reading.type,
  #       upload_datetime: one_day_reading.upload_datetime
  #     )
  #   else
  #     pp "Can't insert, no meter_id #{one_day_reading}"
  #   end
  # rescue ActiveRecord::InvalidForeignKey
  #   pp "Can't insert, missing meter for #{one_day_reading.meter_id}"
  #   pp one_day_reading
  # end

 #  def self.upsert_from_one_day_reading(upsert, one_day_reading)
 # #   pp "Looking for meter id: #{one_day_reading.meter_id}"
 # #   meter_id = Meter.find_by(meter_no: one_day_reading.meter_id)

 #    meter_id = if one_day_reading.type != 'ORIG'
 #                 Meter.find_by(meter_no: one_day_reading.meter_id).id
 #               else
 #                 one_day_reading.meter_id
 #               end

 #    if meter_id.present?
 #      upsert.row({ meter_id: meter_id, date: one_day_reading.date },
 #        meter_id: meter_id,
 #        reading_date: one_day_reading.date,
 #        kwh_data_x48: one_day_reading.kwh_data_x48,
 #        one_day_kwh: one_day_reading.one_day_kwh,
 #        substitute_date: one_day_reading.substitute_date,
 #        status: one_day_reading.type,
 #        upload_datetime: one_day_reading.upload_datetime
 #    )

 #    else
 #      pp "Can't insert, no meter_id #{one_day_reading}"
 #    end
 #  rescue ActiveRecord::InvalidForeignKey
 #    pp "Can't insert, missing meter for #{one_day_reading.meter_id}"
 #    pp one_day_reading
 #  end

  #
  # Methods from one day reading - not require I think?
  #

  # def kwh_halfhour(half_hour_index)
  #   @kwh_data_x48[half_hour_index]
  # end

  # def set_kwh_halfhour(half_hour_index, kwh)
  #   @kwh_data_x48[half_hour_index] = kwh
  #   @one_day_kwh = kwh_data_x48.inject(:+)
  # end

  # def set_days_kwh_x48(days_kwh_data_x48)
  #   @kwh_data_x48 = days_kwh_data_x48
  # end

  # def check_type(type)
  #   if type.nil?
  #     throw EnergySparksBadAMRDataTypeException.new('Unexpected nil AMR bad data type')
  #   elsif !AMR_TYPES.key?(type)
  #     throw EnergySparksBadAMRDataTypeException.new("Unexpected AMR bad data type #{type}")
  #   end
  # end

  # def to_s
  #   date = @date.strftime('%d-%m-%Y')
  #   upload_datetime = @date.strftime('%d-%m-%Y %H:%M')
  #   sub_date = @substitute_date.nil? ? '' : @substitute_date.strftime('%d-%m-%Y')
  #   total = sprintf('%4.1f', @one_day_kwh)
  #   [date, @type, total, upload_datetime, sub_date, @kwh_data_x48].flatten.join(',')
  # end

  # def validate_data
  #   return 0 if !@kwh_data_x48.is_a?(Array)
  #   data_count = 0
  #   (0..47).each do |i|
  #     if kwh_halfhour(i).is_a?(Float) || kwh_halfhour(i).is_a?(Integer)
  #       data_count += 1
  #     end
  #   end
  #   if data_count != 48
  #     logger.info "Incomplete AMR data expecting 48 readings, got #{data_count} for date #{@date}"
  #     logger.info @kwh_data_x48
  #   end
  #   data_count
  # end

  # def <=>(other)
  #   other.class == self.class &&
  #     [meter_id, date, type, substitute_date] <=> [other.meter_id, other.date, other.type, other.substitute_date] &&
  #     one_day_kwh <=> other.one_day_kwh &&
  #     @kwh_data_x48 <=> other.kwh_data_x48
  # end
end
