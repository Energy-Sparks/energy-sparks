# From analytics code - tweaked
require 'dashboard'

class AmrMeterCollection < MeterCollection
  def add_amr_data(meter)
    amr_data = AMRData.new(meter.meter_type)

    hash_of_date_formats = AmrDataFeedConfig.pluck(:id, :date_format).to_h

    # First run through
    AmrDataFeedReading.where(meter_id: meter.id).order(reading_date: :asc).each do |reading|
      reading_date = date_from_string_using_date_format(reading, hash_of_date_formats)
      amr_data.add(reading_date, OneDayAMRReading.new(meter.id, reading_date, 'ORIG', nil, reading.created_at, reading.readings.map(&:to_f)))
    end

    throw ArgumentException if school.meters.empty?
    amr_data
  end

  def date_from_string_using_date_format(reading, hash_of_date_formats)
    date_format = hash_of_date_formats[reading.amr_data_feed_config_id]
    Date.strptime(reading.reading_date, date_format)
  end
end
