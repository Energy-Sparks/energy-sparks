require 'dashboard'

module Solar
  class LowCarbonHubUpserter
    def initialize(installation:, readings:, import_log:)
      @low_carbon_hub_installation = installation
      @readings = readings
      @amr_data_feed_config = @low_carbon_hub_installation.amr_data_feed_config
      @amr_data_feed_import_log = import_log
    end

    def perform
      Rails.logger.info "Upserting #{@readings.count} for #{@low_carbon_hub_installation.rbee_meter_id} at #{@low_carbon_hub_installation.school.name}"
      @readings.each do |meter_type, details|
        mpan_mprn = details[:mpan_mprn]
        readings_hash = details[:readings]

        meter = Meter.where(
          meter_type: meter_type,
          mpan_mprn: mpan_mprn,
          name: meter_type.to_s.humanize,
          low_carbon_hub_installation_id: @low_carbon_hub_installation.id,
          school: @low_carbon_hub_installation.school,
          pseudo: true
        ).first_or_create!

        Amr::DataFeedUpserter.new(data_feed_reading_array(readings_hash, meter.id, mpan_mprn), @amr_data_feed_import_log).perform
        Rails.logger.info "Upserted #{@amr_data_feed_import_log.records_updated} inserted #{@amr_data_feed_import_log.records_imported}for #{@low_carbon_hub_installation.rbee_meter_id} at #{@low_carbon_hub_installation.school.name}"
      end
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
