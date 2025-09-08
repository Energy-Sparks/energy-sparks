require 'dashboard'

module Amr
  class N3rgyDownloader
    def initialize(meter:, start_date:, end_date:)
      @meter = meter
      @start_date = start_date
      @end_date = end_date
    end

    def readings
      # Turn the array of [DateTime, value] into a hash
      readings_by_date_time = fetch_all_readings

      # Creates a hash of { readings: {date => x48 array}, missing_readings: [date_time] }
      # The fourth parameter is set to true to ensure that we correctly process the date times
      # in the list of readings. For a given day d, n3rgy return the final half-hourly reading
      # as midnight of d+1. This conversion function handles this, so that the readings
      # are properly associated with each date
      meter_readings = X48Formatter.convert_dt_to_v_to_date_to_v_x48(@start_date.to_date,
        @end_date.to_date, readings_by_date_time, true, nil)

      # This return format matches the original v1 code. This can be simplified as there is no
      # need to create the one day readings to then just throw them away in the next step
      {
        @meter.meter_type =>
          {
            mpan_mprn:        @meter.mpan_mprn,
            readings:         make_one_day_readings(meter_readings[:readings], @meter.mpan_mprn),
            missing_readings: meter_readings[:missing_readings]
          }
      }
    end

    private

    # TODO remove, unnecessary, see note above
    def make_one_day_readings(meter_readings_by_date, mpan_mprn)
      meter_readings_by_date.map do |date, readings|
        [date.to_date, OneDayAMRReading.new(mpan_mprn, date.to_date, 'ORIG', nil, DateTime.now, readings, true)]
      end.to_h
    end

    # Query the n3rgy API in blocks of up to 90 days to fetch all of the readings
    #
    # start_date is a DateTime with hour/mins of 00:30
    # end_date is a DateTime with hour/mins of 00:00
    #
    # `.each_slice` returns ranges that use the same hours/mins as the start of the
    # sliced range. So we need to adjust the end range before use
    #
    # Slices use 89 days because of this
    #
    #
    # Extracts the readings from each API response, adjusting units as required
    #
    # Returns a single hash of DateTime => half hourly reading value
    def fetch_all_readings
      readings = []
      (@start_date..@end_date).each_slice(89) do |date_range_max_90days|
        start_date_time = date_range_max_90days.first
        end_date_time = (date_range_max_90days.last + 1.day).change({ hour: 0, min: 0, sec: 0 })
        response = api_client.readings(@meter.mpan_mprn,
          @meter.fuel_type.to_s,
          DataFeeds::N3rgy::DataApiClient::READING_TYPE_CONSUMPTION,
          start_date_time,
          end_date_time)
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

      # v2 returns an array of readings for each 'device'. It is technically possible
      # within the SMETS standard for there to be up to 5 devices of the same type,
      # e.g. 5 electricity meters. But this is an edge case and in practice they
      # would all have MPANs.
      warn_if_multiple_devices(response)
      #
      # The responses may also contain a secondaryValue which we are also ignoring
      # for the moment. These are for Twin Element Electricity Meters which monitor
      # two circuits.
      #
      # Individual values can also include an additionalInformation key, to indicate
      # why data is missing which we are not currently using either.
      response['devices'][0]['values'].map do |half_hourly_reading|
        timestamp = DateTime.parse(half_hourly_reading['timestamp'])
        value = case response['unit']
                when 'm3'
                  to_kwh(half_hourly_reading['primaryValue'], timestamp)
                else
                  half_hourly_reading['primaryValue']
                end
        [timestamp, value]
      end
    end

    def to_kwh(value, timestamp)
      LocalDistributionZone.kwh_per_m3(@meter&.school&.local_distribution_zone, timestamp) * value unless value.nil?
    end

    def api_client
      DataFeeds::N3rgy::DataApiClient.production_client
    end

    def warn_if_multiple_devices(response)
      if response['devices'].length > 1
        Rollbar.warning("Multiple devices (#{response['devices'].length}) present in n3rgy readings API",
                      meter: @meter.mpan_mprn,
                      school: @meter.school.name
                    )
      end
    end
  end
end
