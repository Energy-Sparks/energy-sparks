# frozen_string_literal: true

require 'dashboard'

module Solar
  class RtoneVariantUpserter < BaseUpserter
    def perform
      log_perform_start
      Amr::DataFeedUpserter.new(@amr_data_feed_config, @amr_data_feed_import_log,
                                data_feed_reading_array(@readings[:readings],
                                                        @installation.meter.id,
                                                        @installation.meter.mpan_mprn)).perform
      log_perform_upsert
    end

    private

    def data_feed_reading_array(readings_hash, meter_id, mpan_mprn)
      super(readings_hash.transform_values(&:kwh_data_x48), meter_id, mpan_mprn)
    end
  end
end
