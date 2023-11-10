module Solar
  class SolarEdgeLoaderJob < BaseSolarLoaderJob
    private

    def upserter(start_date, end_date)
      Solar::SolarEdgeDownloadAndUpsert.new(installation: @installation, start_date: start_date, end_date: end_date)
    end

    def solar_feed_type
      "Solar Edge"
    end
  end
end
