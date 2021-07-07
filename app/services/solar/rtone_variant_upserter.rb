require 'dashboard'

module Solar
  class RtoneVariantUpserter
    def initialize(rtone_variant_installation:, readings:)
      @rtone_variant_installation = rtone_variant_installation
      @readings = readings
      @amr_data_feed_config = @rtone_variant_installation.amr_data_feed_config
      @amr_data_feed_import_log = AmrDataFeedImportLog.create(amr_data_feed_config_id: @amr_data_feed_config.id, file_name: "Rtone Variant API import #{DateTime.now.utc}", import_time: DateTime.now.utc)
    end

    def perform
      Rails.logger.info "Upserting #{@readings.count} for #{@rtone_variant_installation.rtone_meter_id} at #{@rtone_variant_installation.school.name}"

      readings_hash = @readings[:readings]
      meter = @rtone_variant_installation.meter

      Amr::DataFeedUpserter.new(data_feed_reading_array(readings_hash, meter.id, meter.mpan_mprn), @amr_data_feed_import_log).perform
      Rails.logger.info "Upserted #{@amr_data_feed_import_log.records_updated} inserted #{@amr_data_feed_import_log.records_imported}for #{@rtone_variant_installation.rtone_meter_id} at #{@rtone_variant_installation.school.name}"
    end

    private

    def data_feed_reading_array(readings_hash, meter_id, mpan_mprn)
      readings_hash.map do |reading_date, one_day_amr_reading|
        {
          amr_data_feed_config_id: @amr_data_feed_config.id,
          meter_id: meter_id,
          mpan_mprn: mpan_mprn,
          reading_date: reading_date,
          readings: one_day_amr_reading.kwh_data_x48
        }
      end
    end
  end
end
