module Solar
  class SolarEdgeLoaderJob < ApplicationJob
    include Rails.application.routes.url_helpers

    queue_as :default

    def priority
      5
    end

    def perform(installation, start_date, end_date, notify_email)
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

    def upserter(start_date, end_date)
      Solar::SolarEdgeDownloadAndUpsert.new(installation: @installation, start_date: start_date, end_date: end_date)
    end

    def send_notification(notify_email)
      AdminMailer.with(to: notify_email,
                       title: title,
                       summary: summary,
                       results_url: results_url).background_job_complete.deliver_now
    end

    def send_failure_notification(notify_email, error)
      AdminMailer.with(to: notify_email,
                       title: title,
                       summary: "The job failed to run. An error has been logged: #{error.message}",
                       results_url: nil).background_job_complete.deliver_now
    end

    def title
      "Solar Edge Import for #{@installation.school.name}"
    end

    def summary
      import_log = @upserter.import_log
      if import_log.errors?
        <<~SUMMARY.strip
          The requested import for the Solar Edge Site Id #{@installation.site_id} has failed.
          The import failed: #{import_log.error_messages}.
        SUMMARY
      else
        <<~SUMMARY.strip
          The requested import for the Solar Edge Site Id #{@installation.site_id} has completed.
          #{import_log.records_imported} records were imported and #{import_log.records_updated} updated
        SUMMARY
      end
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
