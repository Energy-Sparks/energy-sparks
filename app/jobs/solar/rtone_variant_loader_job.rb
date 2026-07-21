# frozen_string_literal: true

module Solar
  class RtoneVariantLoaderJob < BaseSolarLoaderJob
    private

    def upserter = Solar::RtoneVariantDownloadAndUpsert
    def solar_feed_type = 'Rtone Variant'
  end
end
