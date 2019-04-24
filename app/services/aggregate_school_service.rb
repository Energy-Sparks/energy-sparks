require 'dashboard'

class AggregateSchoolService
  def initialize(school)
    @school = school
  end

  def aggregate_school
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)

    bm = Benchmark.realtime {
      cache_key = "#{@school.id}-#{@school.name.parameterize}-amr-validated-meter-collection"
      @meter_collection = Rails.cache.fetch(cache_key, expires_in: 1.day) do
        AmrValidatedMeterCollection.new(@school)
      end
    }

    Rails.logger.info "€€€€ loaded AmrValidatedMeterCollection for school in #{bm.round(2)} seconds"

    bm = Benchmark.realtime {
      # Pre-warm environment caches
      @meter_collection.holidays
      @meter_collection.temperatures
      @meter_collection.solar_irradiation
      @meter_collection.solar_pv
    }

    Rails.logger.info "€€€€ loaded weather, holidays etc for school in #{bm.round(2)} seconds"

    aggregate_data_service = AggregateDataService.new(@meter_collection)

    bm = Benchmark.realtime {
      aggregate_data_service.aggregate_heat_and_electricity_meters
    }

    Rails.logger.info "€€€€ Aggregate heat and electricity meters in #{bm.round(2)} seconds"

    aggregated_meter_collection = aggregate_data_service.meter_collection

    bm = Benchmark.realtime {
      Rails.cache.write(cache_key, aggregated_meter_collection)
    }

    Rails.logger.info "€€€€ Add to cache in #{bm.round(2)} seconds"

    aggregated_meter_collection
  end

  def invalidate_cache
    Rails.cache.delete(cache_key)
  end

private

  def cache_key
    "#{@school.id}-#{@school.name.parameterize}-aggregated_meter_collection"
  end
end


# Paulton
# Loading AMR validated MC from DB - 1.465 seconds
# Aggregation - Calculated meter aggregation in 1.58 seconds - this loads holidays, temperatures etc
# Aggregation - Preload holidays, temperatures, solar irradiation etc - 1 to 1.25 seconds

# Just aggregation - 1.22 seconds
# 1.15 seconds


# St Marks
# Meter aggregation in 2.86 seconds
# Aggregated school arrives in 13.9 seconds, 14.31 seconds compress false

# Analytics
# Aggregation - Calculated meter aggregation in 2.69 seconds

# Write to cache - 2.85 seconds

# St Marks

# €€€€ loaded AmrValidatedMeterCollection for school in 3.63 seconds
# €€€€ loaded weather, holidays etc for school in 1.58 seconds
# €€€€ Aggregate heat and electricity meters in 3.04 seconds
# €€€€ Add to cache in 5.89 seconds

# Whole process 14.19 seconds





## Pre-warm holidays etc each day

# €€€€ Pre-warm holidays etc in 0.35 seconds
# €€€€ loaded AmrValidatedMeterCollection for school in 3.25 seconds
# €€€€ loaded weather, holidays etc for school in 0.09 seconds
# €€€€ Aggregate heat and electricity meters in 2.63 seconds
# €€€€ Add to cache in 5.51 seconds
# €€€€ Aggregated school in 11.48 seconds
