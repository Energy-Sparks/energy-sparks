module Amr
  class N3rgyDownloadAndUpsert
    def initialize(
        meter:,
        config:,
        start_date:,
        end_date:,
        n3rgy_api: MeterReadingsFeeds::N3rgy.new(production: Rails.env.production?)
      )
      @meter = meter
      @config = config
      @n3rgy_api = n3rgy_api
      @start_date = start_date
      @end_date = end_date
    end

    def perform
      readings = N3rgyDownloader.new(meter: @meter, start_date: @start_date, end_date: @end_date, n3rgy_api: @n3rgy_api).readings
      N3rgyUpserter.new(meter: @meter, config: @config, readings: readings).perform
    end
  end
end
