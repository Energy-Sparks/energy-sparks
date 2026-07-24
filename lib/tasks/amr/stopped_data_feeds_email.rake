# frozen_string_literal: true

namespace :amr do
  desc 'Send an email when readings not received for a AmrDataFeedConfig'
  task stopped_data_feeds_email: :environment do |_t, _args|
    next unless ENV['SEND_AUTOMATED_EMAILS'] == 'true'

    now = Time.current
    missing = AmrDataFeedConfig.enabled
                               .where.not(source_type: :manual)
                               .where.not(missing_reading_window: nil)
                               .stopped_feeds
                               .filter_map do |config|
                                 latest = config.amr_data_feed_readings.maximum(:updated_at)

                                 [config, now - latest] if latest
                               end

    AdminMailer.with(to: 'operations@energysparks.uk', missing:).stopped_data_feeds.deliver if missing.present?
  end
end
