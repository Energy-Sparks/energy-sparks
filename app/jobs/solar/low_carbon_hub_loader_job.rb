# frozen_string_literal: true

module Solar
  class LowCarbonHubLoaderJob < BaseSolarLoaderJob
    private

    def upserter = Solar::LowCarbonHubDownloadAndUpsert
    def solar_feed_type = 'Rtone'
  end
end
