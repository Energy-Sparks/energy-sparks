# frozen_string_literal: true

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
      log_perform_start
      @readings.each do |meter_type, details|
        attributes = meter_model_attributes(details).stringify_keys
        meter = find_meter_or_create(meter_type, details) do |new_record|
          new_record.assign_attributes({ name: meter_type.to_s.humanize, active: false }.merge(attributes))
        end
        meter.update!(attributes) unless meter.attributes >= attributes
        Amr::DataFeedUpserter.new(@amr_data_feed_config,
                                  @amr_data_feed_import_log,
                                  data_feed_reading_array(details[:readings], meter.id, meter.mpan_mprn)).perform
        log_perform_upsert
      end
    end

    private

    def log_perform_start
      Rails.logger.info "Upserting #{@readings.count} for #{@installation.display_name}"
    end

    def log_perform_upsert
      Rails.logger.info "Updated #{@amr_data_feed_import_log.records_updated} " \
                        "inserted #{@amr_data_feed_import_log.records_imported} " \
                        "for #{@installation.display_name}"
    end

    def find_meter_or_create(meter_type, details, &)
      Meter.find_or_create_by!(meter_type:,
                               mpan_mprn: synthetic_mpan(meter_type, details),
                               school: @installation.school, &)
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
