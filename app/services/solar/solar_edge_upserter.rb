require 'dashboard'

module Solar
  class SolarEdgeUpserter
    def initialize(solar_edge_installation:, readings:, import_log:)
      @solar_edge_installation = solar_edge_installation
      @readings = readings
      @amr_data_feed_config = @solar_edge_installation.amr_data_feed_config
      @amr_data_feed_import_log = import_log
    end

    def perform
      Rails.logger.info "Upserting #{@readings.count} for #{@solar_edge_installation.site_id} at #{@solar_edge_installation.school.name}"
      @readings.each do |meter_type, details|
        mpan_mprn = synthetic_mpan(meter_type, @solar_edge_installation.mpan)
        readings_hash = details[:readings]

        meter = Meter.find_or_create_by!(
          meter_type: meter_type,
          mpan_mprn: mpan_mprn,
          school: @solar_edge_installation.school
        ) do |new_record|
          new_record.name = meter_type.to_s.humanize
          new_record.pseudo = true
          new_record.solar_edge_installation = @solar_edge_installation
        end

        update_existing_meter_if_needed(meter)

        Amr::DataFeedUpserter.new(data_feed_reading_array(readings_hash, meter.id, mpan_mprn), @amr_data_feed_import_log).perform
        Rails.logger.info "Upserted #{@amr_data_feed_import_log.records_updated} inserted #{@amr_data_feed_import_log.records_imported}for #{@solar_edge_installation.site_id} at #{@solar_edge_installation.school.name}"
      end
    end

    private

    # manually created meters may not be associated with the installation, update
    # if not
    def update_existing_meter_if_needed(meter)
      if !meter.pseudo? || meter.solar_edge_installation.nil?
        meter.update!(
          pseudo: true,
          solar_edge_installation: @solar_edge_installation
        )
      end
    end

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
