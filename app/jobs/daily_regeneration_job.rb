class DailyRegenerationJob < ApplicationJob
  queue_as :regeneration

  def perform(school:)
    GoodJob.logger.info("#{DateTime.now.utc} Regeneration for school #{school.name} start")
    Amr::ValidateAndPersistReadingsService.new(school).perform
    AggregateSchoolService.new(school).invalidate_cache
    ContentBatch.new([school], GoodJob.logger).regenerate
    GoodJob.logger.info("#{DateTime.now.utc} Regeneration for school #{school.name} end")
  end
end
