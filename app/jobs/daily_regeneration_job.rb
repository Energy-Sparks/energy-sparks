class DailyRegenerationJob < ApplicationJob
  queue_as :regeneration

  def priority
    10
  end

  def perform(school:)
    GoodJob.logger.info("#{DateTime.now.utc} Regeneration for school #{school.name} start")
    Schools::SchoolRegenerationService.new(school: school, logger: GoodJob.logger).perform
    GoodJob.logger.info("#{DateTime.now.utc} Regeneration for school #{school.name} end")
  rescue => e
    GoodJob.logger.error "Uncaught exception running regeneration for #{school.name}: #{e.class} #{e.message}"
    GoodJob.logger.error e.backtrace.join("\n")
    Rollbar.error(e, job: :daily_regeneration_job, school_id: school.id, school: school.name)
  end
end
