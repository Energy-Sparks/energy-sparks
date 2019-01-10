module Amr
  class UpsertValidatedReadings
    def initialize(validated_meter_collection)
      @validated_meter_collection = validated_meter_collection
    end

    def perform
      electricity_meters = @validated_meter_collection.electricity_meters
      gas_meters = @validated_meter_collection.heat_meters

      pp "Processing: #{electricity_meters.size} electricity meters"
      process_dashboard_meters(electricity_meters)
      pp "Processing: #{gas_meters.size} gas meters"
      process_dashboard_meters(gas_meters)
    end

  private

    def process_dashboard_meters(dashboard_meters)
      return if dashboard_meters.empty?
      dashboard_meters.map do |dashboard_meter|
        next if AmrDataFeedReading.where(meter_id: dashboard_meter.external_meter_id).empty?
        upserted_dashboard_meter = UpsertValidatedReadingsForAMeter.new(dashboard_meter).perform
        CheckingValidatedReadingsForAMeter.new(upserted_dashboard_meter).perform
      end
    end
  end
end
