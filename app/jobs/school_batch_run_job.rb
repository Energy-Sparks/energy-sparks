class SchoolBatchRunJob < ApplicationJob
  self.queue_adapter = :delayed_job
  queue_as :default

  def perform(school_batch_run)
    ActiveRecord::Base.transaction do
      school_batch_run.update(status: :running)
      ContentRegenerator.new(school_batch_run.school, school_batch_run).perform
      school_batch_run.update(status: :done)
    end
  end
end
