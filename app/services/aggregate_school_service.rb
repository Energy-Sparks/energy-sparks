require 'dashboard'

class AggregateSchoolService
  def initialize(school)
    @school = school
  end

  def aggregate_school
    Rails.cache.fetch(cache_key, expires_in: 3.hours) do
      meter_collection = AmrValidatedMeterCollection.new(@school)
      AggregateDataService.new(meter_collection).aggregate_heat_and_electricity_meters_including_storage_and_solar_pv
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

private

  def cache_key
    "#{@school.id}-#{@school.name.parameterize}-aggregated_meter_collection"
  end
end
