module Amr
  class N3rgyTariffsDownloadAndUpsert
    def initialize(meter:, start_date:, end_date:, n3rgy_api_factory: Amr::N3rgyApiFactory.new)
      @meter = meter
      @n3rgy_api_factory = n3rgy_api_factory
      @start_date = start_date
      @end_date = end_date
    end

    def perform
      @import_log = create_import_log
      start_date = read_start_date(@start_date)
      end_date = read_end_date(@end_date)
      n3rgy_api = @n3rgy_api_factory.data_api(@meter)
      tariffs = N3rgyDownloader.new(meter: @meter, start_date: start_date, end_date: end_date, n3rgy_api: n3rgy_api).tariffs
      N3rgyTariffsUpserter.new(meter: @meter, tariffs: tariffs, import_log: @import_log).perform
    rescue => e
      @import_log.update!(error_messages: "Error downloading tariffs from #{start_date} to #{end_date} : #{e.message}")
      Rails.logger.error "Exception: downloading N3rgy tariffs for #{@meter.mpan_mprn} from #{start_date} to #{end_date} : #{e.class} #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      Rollbar.error(e, job: :n3rgy_download, meter_id: @meter.mpan_mprn, start_date: start_date, end_date: end_date)
    end

    private

    def create_import_log
      TariffImportLog.create(
        source: 'n3rgy-api',
        description: "Tariff import for #{@meter.mpan_mprn} at #{DateTime.now.utc}",
        import_time: DateTime.now.utc)
    end

    def read_start_date(start_date)
      #override if specified
      return start_date if start_date.present?
      if @meter.amr_data_feed_readings.any?
        earliest_reading_date = @meter.amr_data_feed_readings.minimum(:reading_date)
        #if there's a gap between earliest available and what we have stored
        #then request all data
        #
        #Note: this could be improved as its potentially inefficient to request all data, could just
        #aim to find the latest gap in readings and fill, so we have enough. Or find all gaps
        #and invoke API multiple times (which would require a larger refactor of this class)
        if earliest_reading_date.present? && @meter.earliest_available_data && Date.parse(earliest_reading_date).after?(@meter.earliest_available_data)
          return @meter.earliest_available_data
        end
        #otherwise if use date of latest reading
        latest_reading_date = @meter.amr_data_feed_readings.maximum(:reading_date)
        return Date.parse(latest_reading_date) if latest_reading_date.present?
      else
        return @meter.earliest_available_data || Time.zone.today - 13.months
      end
    end

    def read_end_date(end_date)
      return end_date.present? ? end_date : Time.zone.today - 1
    end
  end
end
