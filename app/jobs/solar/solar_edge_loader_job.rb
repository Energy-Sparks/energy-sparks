# frozen_string_literal: true

module Solar
  class SolarEdgeLoaderJob < BaseSolarLoaderJob
    private

    def upserter = Solar::SolarEdgeDownloadAndUpsert
    def solar_feed_type = 'Solar Edge'
  end
end
