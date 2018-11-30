# From analytics code - tweaked
require 'dashboard'

class AmrValidatedMeterCollection < AmrMeterCollection
  def add_amr_data(dashboard_meter, active_record_meter)
    amr_data = AMRData.new(dashboard_meter.meter_type)

    AmrValidatedReading.where(meter_id: active_record_meter.id).order(reading_date: :asc).each do |reading|
      amr_data.add(reading.reading_date, OneDayAMRReading.new(active_record_meter.id, reading.reading_date, reading.status, reading.substitute_date, reading.upload_datetime, reading.kwh_data_x48.map(&:to_f)))
    end

    dashboard_meter.amr_data = amr_data
    dashboard_meter
  end
end
