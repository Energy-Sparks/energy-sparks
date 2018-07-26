module SchoolAggregation
  extend ActiveSupport::Concern

private

  def aggregate_school(school)
    cache_key = "#{@school.name.parameterize}-aggregated_meter_collection"
    Rails.cache.fetch(cache_key, expires_in: 1.day) do
      meter_collection = MeterCollection.new(school)
      AggregateDataService.new(meter_collection).validate_and_aggregate_meter_data
    end
  end
end
