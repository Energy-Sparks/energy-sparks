class ContentRegenerator
  def initialize(school, logger)
    @school = school
    @logger = logger
  end

  def perform
    total_amr_readings_before = @school.amr_validated_readings.count

    log('Validating and persisting...')

    Amr::ValidateAndPersistReadingsService.new(@school).perform

    log('Clearing cache...')

    AggregateSchoolService.new(@school).invalidate_cache

    total_amr_readings_after = @school.amr_validated_readings.count

    log("Total validated AMR daily readings for school: #{total_amr_readings_after} - inserted: #{total_amr_readings_after - total_amr_readings_before}")

    ContentBatch.new([@school], @logger).regenerate
    log('Finished')
  end

  private

  def log(msg)
    @logger.info(msg)
  end
end
