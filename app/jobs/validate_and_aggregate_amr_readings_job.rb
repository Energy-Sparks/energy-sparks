class ValidateAndAggregateAmrReadingsJob < ApplicationJob
  self.queue_adapter = :good_job

  def perform(school:)
    Amr::ValidateAndPersistReadingsService.new(school).perform
    AggregateSchoolService.new(school).invalidate_cache
  end

  # after_perform do |job|
  #   return unless arguments[:send_metrics_after_perform]
  #   # Publish total total amr readings to cloudwatch here
  # end
end
