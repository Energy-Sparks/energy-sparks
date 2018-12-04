module Amr
  class UpsertValidatedReadings
    def initialize(school, validated_meter_collection)
      @school = school
      @validated_meter_collection = validated_meter_collection
    end

    def perform
      electricity_meters = @school.meters_with_readings(:electricity)
      gas_meters = @school.meters_with_readings(:gas)

      if electricity_meters.any?
        pp "School has: #{electricity_meters.count} electricity meters"
        @validated_meter_collection.electricity_meters.each do |dashboard_meter|
          UpsertValidatedReadingsForAMeter.new(dashboard_meter).perform
        end
      end

      if gas_meters.any?
        pp "School has: #{gas_meters.count} gas meters"
        @validated_meter_collection.heat_meters.each do |dashboard_meter|
          UpsertValidatedReadingsForAMeter.new(dashboard_meter).perform
        end
      end

      p "Report for #{@school.name}"
      @validated_meter_collection
    end
  end
end
