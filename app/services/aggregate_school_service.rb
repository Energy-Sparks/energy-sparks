require 'dashboard'

class AggregateSchoolService
  def initialize(active_record_school)
    @active_record_school = active_record_school
  end

  def aggregate_school
    Rails.cache.fetch(cache_key) do
      meter_collection = Amr::AnalyticsMeterCollectionFactory.new(@active_record_school).validated

      AggregateDataService.new(meter_collection).aggregate_heat_and_electricity_meters

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

  def self.analysis_date(meter_collection, fuel_type)
    fuel_type = fuel_type.to_sym
    if fuel_type == :gas
      meter_collection.aggregated_heat_meters.amr_data.keys.last
    elsif fuel_type == :electricity
      meter_collection.aggregated_electricity_meters.amr_data.keys.last
    else
      Time.zone.today
    end
  end

  def self.save_to_s3(aggregate_school, bucket:)
    client = Aws::S3::Client.new
    key = "aggregated-meter-collection-#{aggregate_school.school.name.parameterize}.yaml"
    yaml = YAML.dump(aggregate_school)
    client.put_object(
      bucket: bucket,
      key: key,
      content_type: 'application/x-yaml',
      body: yaml
    )
  end

private

  def cache_key
    "#{@active_record_school.id}-#{@active_record_school.name.parameterize}-aggregated_meter_collection-#{@active_record_school.validation_cache_key}"
  end
end
