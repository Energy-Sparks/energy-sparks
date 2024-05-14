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

        meter = Meter.find_or_create_by!(
          meter_type: meter_type,
          mpan_mprn: mpan_mprn,
          school: @low_carbon_hub_installation.school
        ) do |new_record|
          new_record.name = meter_type.to_s.humanize
          new_record.pseudo = true
          new_record.low_carbon_hub_installation = @low_carbon_hub_installation
        end

        update_existing_meter_if_needed(meter)

        Amr::DataFeedUpserter.new(data_feed_reading_array(readings_hash, meter.id, mpan_mprn), @amr_data_feed_import_log).perform
        Rails.logger.info "Upserted #{@amr_data_feed_import_log.records_updated} inserted #{@amr_data_feed_import_log.records_imported}for #{@low_carbon_hub_installation.rbee_meter_id} at #{@low_carbon_hub_installation.school.name}"
      end
    end

    private

    # manually created meters may not be associated with the installation, update
    # if not
    def update_existing_meter_if_needed(meter)
      if !meter.pseudo? || meter.low_carbon_hub_installation.nil?
        meter.update!(
          pseudo: true,
          low_carbon_hub_installation: @low_carbon_hub_installation
        )
      end
    end

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
