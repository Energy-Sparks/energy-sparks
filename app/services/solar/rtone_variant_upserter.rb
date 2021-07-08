require 'dashboard'

module Solar
  class RtoneVariantUpserter
    def initialize(rtone_variant_installation:, readings:, import_log:)
      @rtone_variant_installation = rtone_variant_installation
      @readings = readings
      @import_log = import_log
    end

    def perform
      Rails.logger.info "Upserting #{@readings.count} for #{@rtone_variant_installation.rtone_meter_id} at #{@rtone_variant_installation.school.name}"

      Amr::DataFeedUpserter.new(data_feed_reading_array(@readings[:readings]), @import_log).perform

      Rails.logger.info "Upserted #{@import_log.records_updated} inserted #{@import_log.records_imported}for #{@rtone_variant_installation.rtone_meter_id} at #{@rtone_variant_installation.school.name}"
    end

    private

    def data_feed_reading_array(readings_hash)
      readings_hash.map do |reading_date, one_day_amr_reading|
        {
          amr_data_feed_config_id: @rtone_variant_installation.amr_data_feed_config.id,
          meter_id: meter_id,
          mpan_mprn: mpan_mprn,
          reading_date: reading_date,
          readings: one_day_amr_reading.kwh_data_x48
        }
      end
    end

    def meter_id
      @rtone_variant_installation.meter.id
    end

    def mpan_mprn
      @rtone_variant_installation.meter.mpan_mprn
    end
  end
end
