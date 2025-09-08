# frozen_string_literal: true

module Solar
  class BaseDownloadAndUpsert
    def initialize(start_date:, end_date:, installation:)
      @requested_start_date = start_date
      @requested_end_date = end_date
      @installation = installation
    end

    def perform
      download_and_upsert
    rescue StandardError => e
      EnergySparks::Log.exception(e, job: job, school: school&.name, start_date:, end_date:,
                                     installation_id: @installation.id)
      import_log.update!(error_messages: "Exception: downloading solar data from #{start_date} to #{end_date} : " \
                                         "#{e.class} #{e.message}")
    end

    def import_log
      @import_log ||= AmrDataFeedImportLog.create(
        amr_data_feed_config: @installation.amr_data_feed_config,
        file_name: "#{job.to_s.humanize} import #{DateTime.now.utc}",
        import_time: DateTime.now.utc
      )
    end

    protected

    # implement this in the subclass
    def download_and_upsert
      nil
    end

    # provide a more meaningful job name for logging in subclass
    def job
      :solar_download
    end

    def school
      @installation.try(:school)
    end

    def latest_reading
      @installation.latest_electricity_reading
    end

    def start_date
      if @requested_start_date
        @requested_start_date
      elsif latest_reading.nil?
        nil
      else
        [latest_reading, Date.yesterday - 5].min
      end
    end

    def end_date
      @requested_end_date.presence || Date.yesterday
    end
  end
end
