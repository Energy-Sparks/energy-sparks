module Schools
  class SchoolRegenerationService
    def initialize(school:, logger: Rails.logger)
      @school = school
      @logger = logger
    end

    def perform
      meter_collection = validate_and_persist_readings
      run_aggregation(meter_collection)
      cache_meter_collection(meter_collection)
      regenerate_school_metrics(meter_collection)
    end

    def validate_and_persist_readings
      total_amr_readings_before = @school.amr_validated_readings.count
      meter_collection = Amr::ValidateAndPersistReadingsService.new(@school, @logger).perform
      total_amr_readings_after = @school.amr_validated_readings.count
      @logger.info("Total validated readings for school: #{total_amr_readings_after} - Difference: #{total_amr_readings_after - total_amr_readings_before}")
      meter_collection
    rescue => e
      log_error("Failed to validate and persist readings", e)
      create_meter_collection_from_validated_readings
    end

    def run_aggregation(meter_collection)
      #delegate to analytics service to do the aggregation
      AggregateDataService.new(meter_collection).aggregate_heat_and_electricity_meters
      @logger.info("Aggregated school")
    rescue => e
      log_error("Failed to aggregate school", e)
    end

    def regenerate_school_metrics(meter_collection)
      Schools::SchoolMetricsGeneratorService.new(school: @school, meter_collection: meter_collection, logger: @logger).perform
    rescue => e
      log_error("Failed to regenerate school metrics", e)
    end

    def cache_meter_collection(meter_collection)
      AggregateSchoolService.new(@school).cache(meter_collection)
      @logger.info("Updated Rails cache")
    rescue => e
      log_error("Failed to cache school", e)
    end

    private

    def log_error(msg, exception)
      @logger.error "Exception: #{msg} #{@school.name}: #{exception.class} #{exception.message}"
      @logger.error exception.backtrace.join("\n")
      Rollbar.error(exception, job: :school_regeneration_job, school_id: @school.id, school: @school.name)
    end

    def create_meter_collection_from_validated_readings
      @logger.info("Continuing with validated readings")
      Amr::AnalyticsMeterCollectionFactory.new(@school).validated
    end
  end
end
