require 'dashboard'

module Amr
  class ValidateAndPersistReadingsService
    def initialize(active_record_school, logger = Rails.logger)
      @active_record_school = active_record_school
      @logger = logger
    end

    def perform
      return unless @active_record_school.meters_with_readings.any?

      meter_collection = AnalyticsMeterCollectionFactory.new(@active_record_school).unvalidated

      @logger.info('Created meter collection from unvalidated data')

      AggregateDataService.new(meter_collection).validate_meter_data

      @logger.info('Validated meter data')

      UpsertValidatedReadings.new(meter_collection).perform

      @logger.info('Completed database updates for validated readings')

      @active_record_school.invalidate_cache_key

      meter_collection
    end
  end
end
