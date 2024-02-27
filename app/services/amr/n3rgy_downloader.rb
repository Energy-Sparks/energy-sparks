require 'dashboard'

module Amr
  class N3rgyDownloader
    KWH_PER_M3_GAS = 11.1 # this depends on the calorifc value of the gas and so is an approximate average

    def initialize(meter:, start_date:, end_date:, n3rgy_api: MeterReadingsFeeds::N3rgyData.new)
      @meter = meter
      @n3rgy_api = n3rgy_api
      @start_date = start_date
      @end_date = end_date
    end

    def readings
      if EnergySparks::FeatureFlags.active?(:n3rgy_v2)
        download_readings
      else
        @n3rgy_api.readings(@meter.mpan_mprn, @meter.meter_type, @start_date, @end_date)
      end
    end

    def tariffs
      @n3rgy_api.tariffs(@meter.mpan_mprn, @meter.meter_type, @start_date, @end_date)
    end

    private

    def download_readings
      # Turn the array of [DateTime, value] into a hash
      readings_by_date_time = fetch_all_readings

      # Creates a hash of { readings: {date => x48 array}, missing_readings: [date_time] }
      meter_readings = X48Formatter.convert_dt_to_v_to_date_to_v_x48(@start_date.to_date,
        @end_date.to_date, readings_by_date_time, true, nil)

      # This return format matches the existing v1 code. This can be simplified as there is no
      # need to create the one day readings to then just throw them away in the next step
      {
        @meter.fuel_type =>
          {
            mpan_mprn:        @meter.mpan_mprn,
            readings:         make_one_day_readings(meter_readings[:readings], @meter.mpan_mprn),
            missing_readings: meter_readings[:missing_readings]
          }
      }
    end

    # TODO remove, unnecessary, see note above
    def make_one_day_readings(meter_readings_by_date, mpan_mprn)
      meter_readings_by_date.map do |date, readings|
        [date.to_date, OneDayAMRReading.new(mpan_mprn, date.to_date, 'ORIG', nil, DateTime.now, readings, true)]
      end.to_h
    end

    # Query the n3rgy API in blocks of up to 90 days to fetch all of the readings
    #
    # Extracts the readings from each API response, adjusting units as required
    #
    # Returns a single hash of DateTime => half hourly reading value
    def fetch_all_readings
      readings = []
      (@start_date..@end_date).each_slice(90) do |date_range_max_90days|
        response = api_client.readings(@meter.mpan_mprn,
          @meter.fuel_type.to_s,
          DataFeeds::N3rgy::DataApiClient::READING_TYPE_CONSUMPTION,
          date_range_max_90days.first,
          date_range_max_90days.last)
        readings += extract_readings(response)
      end
      readings.to_h
    end

    # Convert an n3rgy v2 API response into an array of [DateTime, value] values
    #
    # For gas readings, values are converted from cubic meters to kWh using
    # a fixed conversion value.
    def extract_readings(response)
      return [] unless response.dig('devices', 0, 'values').present?

      # TODO
      # v2 returns an array of readings for each 'device' Unclear what these
      # map to in practice. Needs further testing.
      #
      # The responses may also contain a secondaryValue which we are also ignoring
      #
      # Individual values can also include an additionalInformation key which we
      # are not using
      response['devices'][0]['values'].map do |half_hourly_reading|
        value = case response['unit']
                when 'm3'
                  to_kwh(half_hourly_reading['primaryValue'])
                else
                  half_hourly_reading['primaryValue']
                end
        [DateTime.parse(half_hourly_reading['timestamp']), value]
      end
    end

    def to_kwh(value)
      value.nil? ? nil : KWH_PER_M3_GAS * value
    end

    def api_client
      DataFeeds::N3rgy::DataApiClient.production_client
    end
  end
end
