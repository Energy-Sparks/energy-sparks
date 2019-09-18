require 'dashboard'

module Amr
  class LowCarbonHubUpserter
    def initialize(low_carbon_hub_installation:, readings:, amr_data_feed_config:)
      @low_carbon_hub_installation = low_carbon_hub_installation
      @readings = readings
      @amr_data_feed_config = amr_data_feed_config
      @amr_data_feed_import_log = AmrDataFeedImportLog.create(amr_data_feed_config_id: @amr_data_feed_config.id, file_name: nil, import_time: DateTime.now.utc)
    end

    def perform
      Rails.logger.info "Upserting #{@readings.count} for #{@low_carbon_hub_installation.rbee_meter_id} at #{@low_carbon_hub_installation.school.name}"
      @readings.each do |meter_type, details|
        mpan_mprn = details[:mpan_mprn]
        readings_hash = details[:readings]

        meter = Meter.where(
          meter_type: meter_type,
          mpan_mprn: mpan_mprn,
          low_carbon_hub_installation_id: @low_carbon_hub_installation.id,
          school: @low_carbon_hub_installation.school,
          pseudo: true
        ).first_or_create!

        data_feed_reading_array = readings_hash.map do |reading_date, one_day_amr_reading|
          {
            amr_data_feed_config_id: @amr_data_feed_config.id,
            meter_id: meter.id,
            mpan_mprn: mpan_mprn,
            reading_date: reading_date,
            readings: one_day_amr_reading.kwh_data_x48
          }
        end

        records_inserted_count = DataFeedUpserter.new(data_feed_reading_array, @amr_data_feed_import_log.id).perform
        Rails.logger.info "Upserted #{records_inserted_count} for #{@low_carbon_hub_installation.rbee_meter_id} at #{@low_carbon_hub_installation.school.name}"
      end
    end
  end
end
