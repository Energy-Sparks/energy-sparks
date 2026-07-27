# frozen_string_literal: true

module Solar
  class MeterZLoaderJob < BaseSolarLoaderJob
    private

    def upserter = Solar::MeterZDownloadAndUpsert
    def solar_feed_type = 'MeterZ'
  end
end
