module Solar
  class BaseDownloadAndUpsert
    def initialize(start_date:, end_date:, installation:)
      @requested_start_date = start_date
      @requested_end_date = end_date
      @installation = installation
    end

    def perform
      download_and_upsert
    rescue => e
      import_log.update!(error_messages: "Error downloading data from #{start_date} to #{end_date} : #{e.message}")
      Rails.logger.error "Exception: downloading solar data from #{start_date} to #{end_date} : #{e.class} #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      Rollbar.error(e, job: job, school: school.name, start_date: start_date, end_date: end_date)
    end

    protected

    #implement this in the subclass
    def download_and_upsert
      nil
    end

    #provide a more meaningful job name for logging in subclass
    def job
      :solar_download
    end

    def school
      @installation.school
    end

    def latest_reading
      @installation.latest_electricity_reading
    end

    def start_date
      default_start_date = Date.yesterday - 5
      if @requested_start_date
        @requested_start_date
      else
        latest_reading && latest_reading < default_start_date ? latest_reading : default_start_date
      end
    end

    def end_date
      @requested_end_date.present? ? @requested_end_date : Date.yesterday
    end

    def import_log
      @import_log ||= AmrDataFeedImportLog.create(
        amr_data_feed_config: @installation.amr_data_feed_config,
        file_name: "#{job.to_s.humanize} import #{DateTime.now.utc}",
        import_time: DateTime.now.utc)
    end
  end
end
