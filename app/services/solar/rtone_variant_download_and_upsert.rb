module Solar
  class RtoneVariantDownloadAndUpsert
    def initialize(
        rtone_variant_installation:,
        start_date:,
        end_date:
      )
      @rtone_variant_installation = rtone_variant_installation
      @requested_start_date = start_date
      @requested_end_date = end_date
      @import_log = create_import_log
    end

    def perform
      readings = RtoneVariantDownloader.new(rtone_variant_installation: @rtone_variant_installation, start_date: start_date, end_date: end_date, low_carbon_hub_api: low_carbon_hub_api).readings

      RtoneVariantUpserter.new(rtone_variant_installation: @rtone_variant_installation, readings: readings, import_log: @import_log).perform
    rescue => e
      @import_log.update!(error_messages: "Error downloading data from #{start_date} to #{end_date} : #{e.message}")
      Rails.logger.error "Exception: downloading Rtone data for #{meter.mpan_mprn} from #{start_date} to #{end_date} : #{e.class} #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      Rollbar.error(e, job: :rtone_variant_download, school: @rtone_variant_installation.school.name, meter_id: meter.mpan_mprn, start_date: start_date, end_date: end_date)
    end

    private

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

    def meter
      @rtone_variant_installation.meter
    end

    def latest_reading
      @rtone_variant_installation.latest_electricity_reading
    end

    def create_import_log
      AmrDataFeedImportLog.create(
        amr_data_feed_config: @rtone_variant_installation.amr_data_feed_config,
        file_name: "Rtone Variant API import #{DateTime.now.utc}",
        import_time: DateTime.now.utc)
    end

    def low_carbon_hub_api
      @low_carbon_hub_api ||= LowCarbonHubMeterReadings.new(username, password)
    end

    def username
      @rtone_variant_installation.username
    end

    def password
      @rtone_variant_installation.password
    end
  end
end
