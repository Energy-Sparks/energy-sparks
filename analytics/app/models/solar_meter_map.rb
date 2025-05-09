# frozen_string_literal: true

require_relative '../../lib/dashboard/utilities/restricted_key_hash'
# helper class for main solar aggregation service
# keeps track of the meter (between 7-9) meters being manipulated
class SolarMeterMap < RestrictedKeyHash
  MPAN_KEY_MAPPINGS = {
    export_mpan: :export,
    production_mpan: :generation,
    production_mpan2: :generation2,
    production_mpan3: :generation3,
    production_mpan4: :generation4,
    production_mpan5: :generation5
  }.freeze

  def self.unique_keys
    %i[
      export
      generation
      generation2
      generation3
      generation4
      generation5
      self_consume
      mains_consume
      mains_plus_self_consume
      generation_meter_list
    ]
  end

  def self.generation_meters
    %i[
      generation
      generation2
      generation3
      generation4
      generation5
    ]
  end

  def self.optional_keys
    %i[
      generation2
      generation3
      generation4
      generation5
      generation_meter_list
    ]
  end

  # Extract just the meter mappings from a solar_pv_mpan_meter_mapping
  # meter attribute configuration
  def self.meter_mappings(mpan_map)
    mpan_map.select { |k, _v| MPAN_KEY_MAPPINGS.key?(k) }
  end

  # Turn meter attribute key into solar meter type
  def self.meter_type(meter_attribute_key)
    MPAN_KEY_MAPPINGS[meter_attribute_key]
  end

  # Look up meter attribute key for a given solar meter type
  def self.meter_attribute_key(meter_type)
    MPAN_KEY_MAPPINGS.key(meter_type)
  end

  # Default name for solar meters of a specific type
  def self.meter_type_to_name_map
    {
      export: SolarPVPanels::SOLAR_PV_EXPORTED_ELECTRIC_METER_NAME,
      generation: SolarPVPanels::SOLAR_PV_PRODUCTION_METER_NAME,
      self_consume: SolarPVPanels::SOLAR_PV_ONSITE_ELECTRIC_CONSUMPTION_METER_NAME,
      mains_consume: SolarPVPanels::ELECTRIC_CONSUMED_FROM_MAINS_METER_NAME,
      mains_plus_self_consume: SolarPVPanels::MAINS_ELECTRICITY_CONSUMPTION_INCLUDING_ONSITE_PV
    }
  end

  def all_required_key_values_non_nil?
    each do |k, v|
      return false if v.nil? && !self.class.optional_keys.include?(k)
    end
    true
  end

  def number_of_generation_meters
    count { |k, v| self.class.generation_meters.include?(k) && !v.nil? }
  end

  # TODO rename / replace with more meaningful
  def set_nil_value(list_of_keys)
    list_of_keys.each do |k|
      self[k] = nil
    end
  end
end
