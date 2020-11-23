class ContentRegenerator
  def initialize(school, logger)
    @school = school
    @logger = logger
  end

  def perform
    total_amr_readings_before = AmrValidatedReading.count

    log('Validating and persisting...')

    Amr::ValidateAndPersistReadingsService.new(@school).perform

    log('Clearing cache...')

    AggregateSchoolService.new(@school).invalidate_cache

    total_amr_readings_after = AmrValidatedReading.count

    log("Total AMR Readings after: #{total_amr_readings_after} - inserted: #{total_amr_readings_after - total_amr_readings_before}")

    ContentBatch.new([@school], @logger).regenerate

    log('Finished')
  end

  private

  def log(msg)
    @logger.info(msg)
  end
end
