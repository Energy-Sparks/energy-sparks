require 'dashboard'

module Amr
  class LowCarbonHubInstallationFactory
    def initialize(school:, rbee_meter_id:, low_carbon_hub_api: LowCarbonHubMeterReadings.new, amr_data_feed_config:)
      @low_carbon_hub_api = low_carbon_hub_api
      @school = school
      @rbee_meter_id = rbee_meter_id
      @amr_data_feed_config = amr_data_feed_config
      @amr_data_feed_import_log = AmrDataFeedImportLog.create(amr_data_feed_config_id: @amr_data_feed_config.id, file_name: nil, import_time: DateTime.now.utc)

    end

    def perform
      installation = LowCarbonHubInstallation.where(school_id: @school.id, rbee_meter_id: @rbee_meter_id).first_or_create!
      installation.update(information: information.to_json)

      meter_setup(installation)
      installation
    end

    private

    def meter_setup(installation)
      initial_readings.each do |meter_type, details|
        mpan_mprn = details[:mpan_mprn]
        readings_hash = details[:readings]

        meter = Meter.where(meter_type: meter_type, mpan_mprn: mpan_mprn, low_carbon_hub_installation_id: installation.id, school: @school, pseudo: true).first_or_create!

        data_feed_reading_array = readings_hash.map do |reading_date, one_day_amr_reading|
          {
            amr_data_feed_config_id: @amr_data_feed_config.id,
            meter_id: meter.id,
            mpan_mprn: mpan_mprn,
            reading_date: reading_date,
            readings: one_day_amr_reading.kwh_data_x48
          }
        end

        DataFeedUpserter.new(data_feed_reading_array, @amr_data_feed_import_log.id).perform
      end
    end

    def existing_meter?(meter_type, mpan_mprn, low_carbon_hub_installation_id)
      Meter.where(meter_type: meter_type, mpan_mprn: mpan_mprn, low_carbon_hub_installation_id: low_carbon_hub_installation_id, school: @school).present?
    end

    def information
      @low_carbon_hub_api.full_installation_information(@rbee_meter_id)
    end

    def initial_readings
      readings(first_reading_date, first_reading_date + 1.day)
    end

    def first_reading_date
      @first_reading_date ||= @low_carbon_hub_api.first_meter_reading_date(@rbee_meter_id)
    end

    def readings(start_date = Date.yesterday, end_date = Date.yesterday - 5.days)
      @low_carbon_hub_api.download(
        @rbee_meter_id,
        @school.urn,
        start_date,
        end_date
      )
    end
  end
end
