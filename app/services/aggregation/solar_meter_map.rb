# frozen_string_literal: true

# helper class for main solar aggregation service
# keeps track of the meter (between 7-9) meters being manipulated
module Aggregation
  class SolarMeterMap
    MPAN_KEY_MAPPINGS = { export_mpan: :export,
                          production_mpan: :generation,
                          production_mpan2: :generation2,
                          production_mpan3: :generation3,
                          production_mpan4: :generation4,
                          production_mpan5: :generation5 }.freeze

    GENERATION_KEYS = %i[generation
                         generation2
                         generation3
                         generation4
                         generation5].freeze
    private_constant :GENERATION_KEYS

    ALLOWED_KEYS = GENERATION_KEYS + %i[export
                                        self_consume
                                        mains_consume
                                        mains_plus_self_consume].freeze
    private_constant :ALLOWED_KEYS

    # Extract just the meter mappings from a solar_pv_mpan_meter_mapping
    # meter attribute configuration
    def self.meter_mappings(mpan_map)
      mpan_map.select { |k, _v| MPAN_KEY_MAPPINGS.key?(k) }
    end

    # Turn meter attribute key into solar meter type

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

    attr_reader :generation_meters

    def initialize(mains_consume)
      @hash = { mains_consume: }
      @generation_meters = []
    end

    def each(&) = all_meters_with_type.each(&)

    def each_value(&) = all_meters_with_type.map(&:second).each(&)

    def all_required_key_values_non_nil?
      %i[export self_consume mains_consume mains_plus_self_consume].all? { |key| !@hash[key].nil? } &&
        !@generation_meters.empty?
    end

    def nil_generation_meters
      @generation_meters = []
    end

    def add_generation_meter(meter)
      @generation_meters << meter
    end

    def mains_consume
      @hash[:mains_consume]
    end

    def generation
      @generation_meters.first
    end

    def export
      @hash[:export]
    end

    def self_consume
      @hash[:self_consume]
    end

    def mains_plus_self_consume
      @hash[:mains_plus_self_consume]
    end

    def set_meter(key, meter)
      key = meter_type(key) || key
      raise ArgumentError, "invalid key #{key}" unless ALLOWED_KEYS.include?(key)

      if GENERATION_KEYS.include?(key)
        add_generation_meter(meter) unless meter.nil?
      else
        @hash[key] = meter
      end
    end

    private

    def meter_type(meter_attribute_key)
      MPAN_KEY_MAPPINGS[meter_attribute_key]
    end

    def all_meters_with_type = @hash.to_a + @generation_meters.map { |meter| [:generation, meter] }
  end
end
