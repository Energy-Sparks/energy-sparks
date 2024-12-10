# frozen_string_literal: true

module Amr
  module PerseUpsert
    def self.perform(meter)
      config = AmrDataFeedConfig.find_by!(identifier: 'perse-half-hourly-api')
      date = AmrDataFeedReading.where(amr_data_feed_config: config, meter: meter)
                               .order(:reading_date).last&.reading_date || 14.months.ago
      log = AmrDataFeedImportLog.create(
        amr_data_feed_config: config,
        file_name: "Perse API import for #{meter.mpan_mprn} for #{date}",
        import_time: DateTime.now.utc,
        records_imported: 0
      )
      reading_hashes = DataFeeds::PerseApi.meter_history_readings(meter.mpan_mprn, date).map do |reading_date, readings|
        { mpan_mprn: meter.mpan_mprn,
          reading_date:,
          readings:,
          amr_data_feed_config_id: config.id,
          meter_id: meter.id }
      end
      DataFeedUpserter.new(config, log, reading_hashes).perform
    rescue StandardError => e
      EnergySparks::Log.exception(e, job: :perse_upsert, meter_id: meter.mpan_mprn)
      msg = "Error downloading data for #{meter.mpan_mprn} from #{date} : #{e.message}"
      log&.update!(error_messages: msg)
      log
    end
  end
end
