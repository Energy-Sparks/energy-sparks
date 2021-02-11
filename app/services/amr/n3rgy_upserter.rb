require 'dashboard'

module Amr
  class N3rgyUpserter
    def initialize(meter:, config:, readings:)
      @meter = meter
      @amr_data_feed_config = config
      @readings = readings
      @amr_data_feed_import_log = AmrDataFeedImportLog.create(amr_data_feed_config_id: @amr_data_feed_config.id, file_name: "N3rgy API import #{DateTime.now.utc}", import_time: DateTime.now.utc)
    end

    def perform
      Rails.logger.info "Upserting #{meter_readings} for #{@meter.mpan_mprn} at #{@meter.school.name}"
      DataFeedUpserter.new(data_feed_reading_array(meter_readings), @amr_data_feed_import_log).perform
      Rails.logger.info "Upserted #{@amr_data_feed_import_log.records_updated} inserted #{@amr_data_feed_import_log.records_imported} for #{@meter.mpan_mprn} at #{@meter.school.name}"
    end

    private

    def meter_readings
      @readings[@meter.meter_type][:readings]
    end

    def data_feed_reading_array(readings_hash)
      readings_hash.map do |reading_date, one_day_amr_reading|
        {
          amr_data_feed_config_id: @amr_data_feed_config.id,
          meter_id: @meter.id,
          mpan_mprn: @meter.mpan_mprn,
          reading_date: reading_date,
          readings: one_day_amr_reading.kwh_data_x48
        }
      end
    end
  end
end
