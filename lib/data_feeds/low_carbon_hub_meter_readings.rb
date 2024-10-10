# frozen_string_literal: true

# downloads low carbon hub meter readings for a school given a single low carbon hub meter id
#
# download() returns 3 sets of meter readings: solar pv production, export, and mains consumption:
#
#   readings_hash[:solar_pv||:electricity||:exported_solar_pv] = { mpan_mprn: mpan, readings: readings{} missing_readings: DateTime[]
#
#   where readings{} = meter_readings[date] => OneDayAMRReading.new()
#
# use first_meter_reading_date(meter_id) if this is the first time data has been retrieved to determine the official start date
# for meter readings, although in the example of Long Furlong, it doesn't seem to be until a few days later that the data
# becomes non-zero
#
# all data is return in local time; RbeeSolarPV - adjusts from the underlying UTC to GMT/BST
#
# there seem to be a few (x14) completely missing days of export data for Long Fulong just after the meter was installed
# in Sep/Oct 2016 - these are currently forwarded with the dates missing, but this may need to be revisited if
# it is a more persistent problem at other schools
#
module DataFeeds
  class LowCarbonHubMeterReadings
    def initialize(username = ENV.fetch('ENERGYSPARKSRBEEUSERNAME', nil),
                   password = ENV.fetch('ENERGYSPARKSRBEEPASSWORD', nil))
      @rbee = RbeeSolarPV.new(username, password)
    end

    # return a 3 key hash[solar_pv electricity exported_solar_pv] => { mpan_mprn: 1234, readings: OneDayAMRReading[], missing_readings: DateTime[] }
    def download(meter_id, urn, start_date, end_date)
      start_date = @rbee.first_connection_date(meter_id) if start_date.nil?
      end_date = @rbee.last_connection_date(meter_id) if end_date.nil?

      data = @rbee.smart_meter_data(meter_id, start_date, end_date)
      convert_raw_readings_to_meter_readings(data, urn, start_date, end_date)
    end

    def download_by_component(meter_id, component, synthetic_mpan, start_date, end_date)
      start_date = @rbee.first_connection_date(meter_id) if start_date.nil?
      end_date = @rbee.last_connection_date(meter_id) if end_date.nil?

      raw_data = @rbee.smart_meter_data_by_component(meter_id, start_date, end_date, component)
      actual_start = start_date || first_meter_reading_date(meter_id)
      {
        mpan_mprn: synthetic_mpan,
        readings: convert_date_to_x48_to_one_day_readings(raw_data[:readings], synthetic_mpan, actual_start, end_date),
        missing_readings: raw_data[:missing_readings]
      }
    end

    def first_meter_reading_date(meter_id)
      @rbee.first_connection_date(meter_id)
    end

    def full_installation_information(low_carbon_hub_meter_id)
      @rbee.full_installation_information(low_carbon_hub_meter_id) # key value pair hash, as per rbee API
    end

    private

    def convert_raw_readings_to_meter_readings(data, urn, start_date, end_date)
      reading_sets = {}
      data.each do |type, data_for_type|
        reading_sets[type] = convert_to_meter_readings(data_for_type, type, urn, start_date, end_date)
      end
      reading_sets
    end

    def convert_to_meter_readings(raw_data, type, urn, start_date, end_date)
      mpan_mprn = Dashboard::Meter.synthetic_combined_meter_mpan_mprn_from_urn(urn, type)
      {
        mpan_mprn:,
        readings: convert_date_to_x48_to_one_day_readings(raw_data[:readings], mpan_mprn, start_date, end_date),
        missing_readings: raw_data[:missing_readings]
      }
    end

    def convert_date_to_x48_to_one_day_readings(raw_meter_readings, mpan_mprn, start_date, end_date)
      meter_readings = {}
      (start_date..end_date).each do |date|
        if raw_meter_readings.key?(date)
          meter_readings[date] =
            OneDayAMRReading.new(mpan_mprn, date, 'ORIG', nil, DateTime.now, raw_meter_readings[date])
        else
          meter_readings[date] =
            OneDayAMRReading.new(mpan_mprn, date, 'ORIG', nil, DateTime.now, Array.new(48, 0.0))
          message = "Warning: missing meter readings for #{mpan_mprn} on #{date}"
          Rails.logger.warn message
        end
      end
      meter_readings
    end
  end
end
