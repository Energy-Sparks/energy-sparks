require 'dashboard'

module Amr
  class N3rgyDownloader
    def initialize(
        meter:,
        start_date:,
        end_date:,
        n3rgy_api: MeterReadingsFeeds::N3rgyData.new
      )
      @meter = meter
      @n3rgy_api = n3rgy_api
      @start_date = start_date
      @end_date = end_date
    end

    def readings
      @n3rgy_api.readings(
        @meter.mpan_mprn,
        @meter.meter_type,
        @start_date,
        @end_date
      )
    end
  end
end
