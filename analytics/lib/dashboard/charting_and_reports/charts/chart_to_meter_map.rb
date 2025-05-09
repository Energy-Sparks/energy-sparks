# frozen_string_literal: true

require 'singleton'

class ChartToMeterMap
  class UnknownChartMeterDefinition < StandardError; end

  include Singleton

  def meter(meter_collection, meter_definition, sub_meter_definition = nil)
    meter = logical_meter_names(meter_collection, meter_definition)
    return meter unless meter == :not_mapped
    if mpxn?(meter_definition)
      meter = meter_collection.meter?(meter_definition, true)
      return meter if (meter.nil? || sub_meter_definition.nil?)
      return meter.sub_meters[sub_meter_definition]
    end

    raise UnknownChartMeterDefinition, "Unknown chart meter definition type #{meter_definition}"
  end

  private

  def mpxn?(meter_definition)
    meter_definition.is_a?(String) || meter_definition.is_a?(Integer)
  end

  def logical_meter_names(meter_collection, meter_definition) # rubocop:disable Metrics/CyclomaticComplexity
    case meter_definition
    when :all then                                        [meter_collection.aggregated_electricity_meters, meter_collection.aggregated_heat_meters]
    when :allheat then                                    meter_collection.aggregated_heat_meters
    when :allelectricity then                             meter_collection.aggregated_electricity_meters
    when :allelectricity_unmodified then                  meter_collection.aggregated_electricity_meters&.original_meter
    when :allelectricity_without_community_use then       meter_collection.aggregated_electricity_meter_without_community_usage
    when :allheat_without_community_use then              meter_collection.aggregated_heat_meters_without_community_usage
    when :storage_heaters_without_community_use then      meter_collection.storage_heater_meter_without_community_usage
    when :storage_heater_meter then                       meter_collection.storage_heater_meter
    when :solar_pv_meter, :solar_pv then                  meter_collection.aggregated_electricity_meters.sub_meters[:generation]
    when :unscaled_aggregate_target_electricity then      meter_collection.unscaled_target_meters[:electricity]
    when :unscaled_aggregate_target_gas then              meter_collection.unscaled_target_meters[:gas]
    when :unscaled_aggregate_target_storage_heater then   meter_collection.unscaled_target_meters[:storage_heater]
    when :synthetic_aggregate_target_electricity then     meter_collection.synthetic_target_meters[:electricity]
    when :synthetic_aggregate_target_gas then             meter_collection.synthetic_target_meters[:gas]
    when :synthetic_aggregate_target_storage_heater then  meter_collection.synthetic_target_meters[:storage_heater]
    else
      :not_mapped
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
end
