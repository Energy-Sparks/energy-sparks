class DailyRegenerationJob < ApplicationJob
  queue_as :regeneration

  def perform(school:)
    GoodJob.logger.info("#{DateTime.now.utc} Regeneration for school #{school.name} start")
    run_validate_and_persist_readings_service_for(school)
    run_aggregate_school_service_for(school)
    run_content_batch_for(school)
    GoodJob.logger.info("#{DateTime.now.utc} Regeneration for school #{school.name} end")
  end

  def run_aggregate_school_service_for(school)
    AggregateSchoolService.new(school).invalidate_cache
  rescue => e
    GoodJob.logger.error "Exception: running AggregateSchoolService in DailyRegenerationJob for #{school.name}: #{e.class} #{e.message}"
    GoodJob.logger.error e.backtrace.join("\n")
    Rollbar.error(e, job: :daily_regeneration_job, school_id: school.id, school: school.name)
  end

  def run_validate_and_persist_readings_service_for(school)
    Amr::ValidateAndPersistReadingsService.new(school).perform
  rescue => e
    GoodJob.logger.error "Exception: running Amr::ValidateAndPersistReadingsService in DailyRegenerationJob for #{school.name}: #{e.class} #{e.message}"
    GoodJob.logger.error e.backtrace.join("\n")
    Rollbar.error(e, job: :daily_regeneration_job, school_id: school.id, school: school.name)
  end

  def run_content_batch_for(school)
    ContentBatch.new([school], GoodJob.logger).regenerate
  end
end
