require 'dashboard'

module Solar
  class BaseUpserter
    def initialize(installation:, readings:, import_log:)
      @installation = installation
      @readings = readings
      @amr_data_feed_config = installation.amr_data_feed_config
      @amr_data_feed_import_log = import_log
    end

    def perform
      Rails.logger.info "Upserting #{@readings.count} for #{@installation.display_name} at #{@installation.school.name}"
      @readings.each do |meter_type, details|
        mpan_mprn = synthetic_mpan(meter_type, details)
        meter = Meter.find_or_create_by!(meter_type: meter_type,
                                         mpan_mprn: mpan_mprn,
                                         school: @installation.school) do |new_record|
          new_record.assign_attributes(meter_attributes(details))
        end
        meter.update!(meter_attributes(details)) unless meter.attributes >= meter_attributes(details)
        Amr::DataFeedUpserter.new(@amr_data_feed_config,
                                  @amr_data_feed_import_log,
                                  data_feed_reading_array(details[:readings], meter.id, mpan_mprn)).perform
        Rails.logger.info "Upserted #{@amr_data_feed_import_log.records_updated} " \
                          "inserted #{@amr_data_feed_import_log.records_imported} " \
                          "for #{@installation.display_name} at #{@installation.school.name}"
      end
    end

    private

    def synthetic_mpan(meter_type, mpan)
      Dashboard::Meter.synthetic_combined_meter_mpan_mprn_from_urn(mpan, meter_type)
    end

    def data_feed_reading_array(readings_hash, meter_id, mpan_mprn)
      readings_hash.map do |reading_date, kwh_data_x48|
        {
          amr_data_feed_config_id: @amr_data_feed_config.id,
          meter_id: meter_id,
          mpan_mprn: mpan_mprn,
          reading_date: reading_date,
          readings: kwh_data_x48
        }
      end
    end
  end
end
