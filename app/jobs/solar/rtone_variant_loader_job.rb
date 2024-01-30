module Solar
  class RtoneVariantLoaderJob < BaseSolarLoaderJob
    private

    def upserter(start_date, end_date)
      Solar::RtoneVariantDownloadAndUpsert.new(installation: @installation, start_date: start_date, end_date: end_date)
    end

    def solar_feed_type
      'Rtone Variant'
    end
  end
end
