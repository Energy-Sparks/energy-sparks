# frozen_string_literal: true

module MeterAttributeTypes
  class AttributeBase
    class_attribute :attribute_key, :attribute_aggregation, :attribute_name, :attribute_structure, :attribute_id, :attribute_description, :attribute_meter_types, :attribute_pseudo_meter_types, :internal

    def self.id(value)
      self.attribute_id = value
    end

    def self.key(key)
      self.attribute_key = key
    end

    def self.aggregate_over(key)
      self.attribute_aggregation = key
    end

    def self.description(description)
      self.attribute_description = description
    end

    def self.name(name)
      self.attribute_name = name
    end

    def self.structure(structure)
      self.attribute_structure = structure
    end

    def self.parse(input)
      new(attribute_structure.parse(input))
    end

    def self.applicable_meter_types
      applicable_attribute_meter_types + applicable_attribute_pseudo_meter_types
    end

    def self.applicable_attribute_meter_types
      attribute_meter_types || [:gas, :electricity, :solar_pv, :exported_solar_pv]
    end

    def self.applicable_attribute_pseudo_meter_types
      attribute_pseudo_meter_types || PSEUDO_METER_TYPES
    end

    def self.internal?
      self.internal || false
    end

    def self.analytics_internal(internal = true)
      self.internal = internal
    end

    def initialize(value)
      @value = value
    end

    def to_analytics
      if attribute_key
        { attribute_key => @value }
      else
        @value
      end
    end
  end
end
