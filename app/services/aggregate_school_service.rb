# frozen_string_literal: true

require 'dashboard'

class AggregateSchoolService
  def initialize(active_record_school, meter_collection = nil)
    @active_record_school = active_record_school
    @meter_collection = meter_collection
  end

  def meter_collection
    @meter_collection ||= aggregate_school
  end

  def aggregate_school
    Rails.cache.fetch(cache_key) do
      meter_collection = Amr::AnalyticsMeterCollectionFactory.new(@active_record_school).validated

      AggregateDataService.new(meter_collection).aggregate_heat_and_electricity_meters

      meter_collection
    end
  end

  # overwrite whatever we have cached
  def cache(meter_collection)
    Rails.cache.write(cache_key, meter_collection)
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
    !Rails.application.config.action_controller.perform_caching
  end

  def self.analysis_date(meter_collection, fuel_type)
    case fuel_type&.to_sym
    when :gas
      meter_collection.aggregated_heat_meters.amr_data.end_date
    when :electricity, :storage_heater
      meter_collection.aggregated_electricity_meters.amr_data.end_date
    else
      Time.zone.today
    end
  end

  private

  def cache_key
    parts = [@active_record_school.id, @active_record_school.name.parameterize, 'aggregated_meter_collection']
    unless Flipper.enabled?(:meter_collection_cache_delete_on_invalidate)
      parts << @active_record_school.validation_cache_key
    end
    parts.join('-')
  end
end
