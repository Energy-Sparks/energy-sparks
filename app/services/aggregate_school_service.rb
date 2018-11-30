require 'dashboard'

class AggregateSchoolService
  def initialize(school)
    @school = school
  end

  def aggregate_school
    cache_key = "#{@school.name.parameterize}-aggregated_meter_collection"
    Rails.cache.fetch(cache_key, expires_in: 3.hours) do
      meter_collection = AmrValidatedMeterCollection.new(@school)
      AggregateDataService.new(meter_collection).aggregate_heat_and_electricity_meters_including_storage_and_solar_pv
      # Pre-warm holiday cache
      meter_collection.holidays
      meter_collection.temperatures
      meter_collection
    end
  end
end
