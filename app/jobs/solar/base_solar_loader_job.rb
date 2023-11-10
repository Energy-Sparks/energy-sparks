module Solar
  #Base class for all the jobs that load solar data
  class BaseSolarLoaderJob < ApplicationJob
    include Rails.application.routes.url_helpers

    queue_as :default

    def priority
      5
    end

    def perform(installation:, notify_email:, start_date: nil, end_date: nil)
      @installation = installation
      @upserter = upserter(start_date, end_date)
      @upserter.perform
      send_notification(notify_email)
    rescue => e
      Rollbar.error(e, job: :import_solar_edge_readings)
      send_failure_notification(notify_email, e)
      false
    end

    private

    def send_notification(notify_email)
      SolarLoaderJobMailer.with(to: notify_email,
                       solar_feed_type: solar_feed_type,
                       installation: @installation,
                       import_log: @upserter.import_log).job_complete.deliver_now
    end

    def send_failure_notification(notify_email, error)
      SolarLoaderJobMailer.with(to: notify_email,
                      solar_feed_type: solar_feed_type,
                      installation: @installation,
                      error: error).job_failed.deliver_now
    end

    def results_url
      if @upserter.import_log.errors?
        admin_reports_amr_data_feed_import_logs_errors_path({ config: { config_id: @upserter.import_log.amr_data_feed_config.id } })
      else
        school_meters_path(@installation.school)
      end
    end
  end
end
