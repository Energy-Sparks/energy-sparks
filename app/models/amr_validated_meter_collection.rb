# From analytics code - tweaked
require 'dashboard'

class AmrValidatedMeterCollection < AmrMeterCollection
  def add_amr_data(meter)
    amr_data = AMRData.new(meter.meter_type)

    AmrValidatedReading.where(meter_id: meter.id).order(reading_date: :asc).each do |reading|
      amr_data.add(reading.reading_date, OneDayAMRReading.new(meter.id, reading.reading_date, reading.status, reading.substitute_date, reading.upload_datetime, reading.kwh_data_x48.map(&:to_f)))
    end

    throw ArgumentException if school.meters.empty?
    amr_data
  end
end
