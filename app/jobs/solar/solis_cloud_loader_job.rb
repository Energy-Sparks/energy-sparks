# frozen_string_literal: true

module Solar
  class SolisCloudLoaderJob < BaseSolarLoaderJob
    private

    def upserter = Solar::SolisCloudDownloadAndUpsert
    def solar_feed_type = 'SolisCloud'
  end
end
