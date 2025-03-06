class SchoolBatchRunJob < ApplicationJob
  queue_as :default

  def priority
    5
  end

  def perform(school_batch_run)
    school_batch_run.info('STARTED')
    school_batch_run.update(status: :running)
    success = Schools::SchoolRegenerationService.new(school: school_batch_run.school, logger: school_batch_run).perform
    school_batch_run.info(success ? 'FINISHED' : 'FAILED')
    school_batch_run.update(status: :done)
  rescue => e
    school_batch_run.error(e.message)
    school_batch_run.info('FAILED')
    school_batch_run.update(status: :failed)
    # ensure job is marked as failed by re-throwing exception
    raise
  end
end
