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

  def analytics_meter(meter)
    meter_collection = aggregate_school
    if meter.fuel_type == :gas
      meter_collection.heat_meters.detect { |m| m.mpan_mprn == meter.mpan_mprn }
    elsif meter.fuel_type == :electricity
      meter_collection.electricity_meters.detect { |m| m.mpan_mprn == meter.mpan_mprn }
    end
  end

  def solar_pv?(meter)
    solar_pv(meter)
  end

  def storage_heater?(meter)
    storage_heaters(meter)
  end

  def meter_corrections(meter)
    MeterAttributes.attributes(analytics_meter(meter), :meter_corrections)
  end

  def aggregation(meter)
    MeterAttributes.attributes(analytics_meter(meter), :aggregation)
  end

  def heating_model(meter)
    MeterAttributes.attributes(analytics_meter(meter), :heating_model)
  end

  def storage_heaters(meter)
    MeterAttributes.attributes(analytics_meter(meter), :storage_heaters)
  end

  def solar_pv(meter)
    MeterAttributes.attributes(analytics_meter(meter), :solar_pv)
  end

private

  def cache_key
    "#{@school.id}-#{@school.name.parameterize}-aggregated_meter_collection"
  end
end
