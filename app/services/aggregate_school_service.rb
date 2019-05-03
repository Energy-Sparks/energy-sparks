require 'dashboard'

class AggregateSchoolService
  def initialize(school)
    @school = school
  end

  def aggregate_school
    Rails.cache.fetch(cache_key, expires_in: 1.day) do
      meter_collection = AmrValidatedMeterCollection.new(@school)
      AggregateDataService.new(meter_collection).validate_and_aggregate_meter_data
      # Pre-warm environment caches
      meter_collection.holidays
      meter_collection.temperatures
      meter_collection.solar_irradiation
      meter_collection.solar_pv
      meter_collection
    end
  end

  def invalidate_cache
    Rails.cache.delete(cache_key)
  end

  def in_cache?
    Rails.cache.exist?(cache_key)
  end

  def in_cache_or_cache_off?
    in_cache? || self.class.caching_off?
  end

  def self.caching_off?
    ! Rails.application.config.action_controller.perform_caching
  end

private

  def cache_key
    "#{@school.id}-#{@school.name.parameterize}-aggregated_meter_collection"
  end
end
