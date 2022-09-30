class ValidateAndAggregateAmrReadingsJob < ApplicationJob
  queue_as :default

  def perform(school)
    Amr::ValidateAndPersistReadingsService.new(school).perform
    AggregateSchoolService.new(school).invalidate_cache
  end
end
