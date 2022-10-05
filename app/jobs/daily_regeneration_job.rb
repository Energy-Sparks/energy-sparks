class DailyRegenerationJob < ApplicationJob
  queue_as :regeneration

  def perform(school:)
    total_amr_readings_before = AmrValidatedReading.count

    GoodJob.logger.info("Validating and persisting #{school.name}...")
    Amr::ValidateAndPersistReadingsService.new(school).perform

    GoodJob.logger.info("Clearing cache for #{school.name}...")
    AggregateSchoolService.new(school).invalidate_cache

    total_amr_readings_after = AmrValidatedReading.count
    GoodJob.logger.info("Total AMR Readings after #{school.name}: #{total_amr_readings_after} - inserted: #{total_amr_readings_after - total_amr_readings_before}")

    ContentBatch.new([school], GoodJob.logger).regenerate
    GoodJob.logger.info("Finished daily regeneration for #{school.name}")
  end
end
