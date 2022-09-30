class ValidateAndAggregateAmrReadingsJob < ApplicationJob
  self.queue_adapter = :delayed_job
  queue_as :validate_amr_readings

  def perform(school:, send_metrics_after_perform: false)
    Amr::ValidateAndPersistReadingsService.new(school).perform
    AggregateSchoolService.new(school).invalidate_cache
  end

  after_perform do |job|
    return unless arguments[:send_metrics_after_perform]
    # Publish total total amr readings to cloudwatch here
  end
end
