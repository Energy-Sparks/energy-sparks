module Solar
  class SolisCloudLoaderJob < BaseSolarLoaderJob
    private

    def upserter(start_date, end_date)
      Solar::SolisCloudDownloadAndUpsert.new(installation: @installation, start_date:, end_date:)
    end

    def solar_feed_type
      'SolisCloud'
    end
  end
end
