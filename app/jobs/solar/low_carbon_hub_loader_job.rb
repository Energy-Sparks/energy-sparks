module Solar
  class LowCarbonHubLoaderJob < BaseSolarLoaderJob
    private

    def upserter(start_date, end_date)
      Solar::LowCarbonHubDownloadAndUpsert.new(installation: @installation, start_date: start_date, end_date: end_date)
    end

    def solar_feed_type
      "Rtone"
    end
  end
end
