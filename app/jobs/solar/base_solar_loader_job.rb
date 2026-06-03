# frozen_string_literal: true

module Solar
  # Base class for all the jobs that load solar data
  class BaseSolarLoaderJob < ApplicationJob
    include Rails.application.routes.url_helpers

    queue_as :default

    def perform(installation:, notify_email:, start_date: nil, end_date: nil)
      @installation = installation
      @upserter = upserter(start_date, end_date)
      @upserter.perform
      send_notification(notify_email, import_log: @upserter.import_log)
    rescue StandardError => e
      EnergySparks::Log.exception(e, job: :import_solar_edge_readings)
      send_notification(notify_email, error: e)
      false
    end

    private

    def upserter(_start_date, _end_date)
      raise 'Not implemented'
    end

    def solar_feed_type
      raise 'Not implemented'
    end

    def send_notification(notify_email, import_log: nil, error: false)
      SolarLoaderJobMailer.with(to: notify_email,
                                solar_feed_type: solar_feed_type,
                                installation: @installation,
                                import_log:,
                                error:).job_complete.deliver_now
    end
  end
end
