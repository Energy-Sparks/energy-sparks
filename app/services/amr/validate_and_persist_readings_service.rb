module Amr
  class ValidateAndPersistReadingsService
    def initialize(school)
      @school = school
      @meter_collection = AmrMeterCollection.new(@school)
    end

    def perform
      return unless @school.meters_with_readings.any?
      p "Validate and persist readings for #{@school.name} #{@school.id}"
      AggregateDataService.new(@meter_collection).validate_meter_data
      UpsertValidatedReadings.new(@meter_collection).perform
      p "ValidateAndPersistReadingsService Report for #{@school.name}"
      @meter_collection
    end
  end
end
