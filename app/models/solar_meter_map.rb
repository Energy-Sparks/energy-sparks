# frozen_string_literal: true

# helper class for main solar aggregation service
# keeps track of the meter (between 7-9) meters being manipulated
class SolarMeterMap
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

  def initialize(mains_electricity_meter)
    @hash = {}
    @hash[:mains_consume] = mains_electricity_meter
    @generation_meters = []
  end

  delegate(:[], to: :@hash)
  delegate(:each, to: :@hash)
  delegate(:each_value, to: :@hash)

  def all_required_key_values_non_nil?
    @hash.each do |k, v|
      return false if v.nil? && self.class.optional_keys.exclude?(k)
    end
    true
  end

  def nil_generation_meters
    self.class.generation_meters.each do |k|
      @hash[k] = nil
    end
    @generation_meters = []
  end

  def generation_meters
    @hash.select do |type, meter|
      self.class.generation_meters.include?(type) && !meter.nil?
    end.values + @generation_meters
  end

  def add_generation_meter(meter)
    @generation_meters << meter
  end

  def mains_consume
    @hash[:mains_consume]
  end

  def set_meter(key, meter)
    @hash[self.class.meter_type(key) || key] = meter
  end
end
