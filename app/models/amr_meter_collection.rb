# From analytics code - tweaked
require 'dashboard'

class AmrMeterCollection < MeterCollection
  def add_amr_data(meter)
    amr_data = AMRData.new(meter.meter_type)

    # First run through
    AmrDataFeedReading.where(meter_id: meter.id).order(reading_date: :asc).each do |reading|
      amr_data.add(Date.parse(reading.reading_date), OneDayAMRReading.new(meter.id, Date.parse(reading.reading_date), 'ORIG', nil, reading.created_at, reading.readings.map(&:to_f)))
    end

    throw ArgumentException if school.meters.empty?
    amr_data
  end
end
