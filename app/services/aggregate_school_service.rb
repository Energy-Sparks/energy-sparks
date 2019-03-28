require 'dashboard'

class AggregateSchoolService
  def initialize(school)
    @school = school
  end

  def aggregate_school
    Rails.cache.fetch(cache_key, expires_in: 3.hours) do
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

  def fuel_types_for_analysis(threshold = AmrValidatedMeterCollection::NUMBER_OF_READINGS_REQUIRED_FOR_ANALYTICS)
    if is_school_dual_fuel?
      dual_fuel_fuel_type
    elsif @school.has_enough_readings_for_meter_types?(:electricity, threshold)
      electricity_fuel_type
    elsif @school.has_enough_readings_for_meter_types?(:gas, threshold)
      :gas_only
    else
      :none
    end
  end

  def is_school_dual_fuel?(threshold = AmrValidatedMeterCollection::NUMBER_OF_READINGS_REQUIRED_FOR_ANALYTICS)
    @school.has_enough_readings_for_meter_types?(:gas, threshold) && @school.has_enough_readings_for_meter_types?(:electricity, threshold)
  end

  def dual_fuel_fuel_type
    @school.has_solar_pv? ? :electric_and_gas_and_solar_pv : :electric_and_gas
  end

  def electricity_fuel_type
    @school.has_storage_heaters? ? :electric_and_storage_heaters : :electric_only
  end

private

  def cache_key
    "#{@school.id}-#{@school.name.parameterize}-aggregated_meter_collection"
  end
end
