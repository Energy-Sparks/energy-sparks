require_relative '../../lib/dashboard/utilities/time_of_year.rb'
require_relative '../../lib/dashboard/utilities/time_of_day.rb'
require 'date'
require 'active_support/core_ext/class/attribute'
require 'json'
module MeterAttributeTypes

  class InvalidAttributeValue < StandardError; end

  PSEUDO_METER_TYPES = [
    :aggregated_electricity,
    :aggregated_gas,
    :solar_pv_consumed_sub_meter,
    :solar_pv_exported_sub_meter,
    :solar_pv_original_sub_meter,
    :storage_heater_aggregated,
    :storage_heater_disaggregated_electricity,
    :storage_heater_disaggregated_storage_heater,
    :school_level_data,
  ].freeze

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
        {attribute_key => @value}
      else
        @value
      end
    end
  end

  class AttributeType

    class_attribute :type

    def initialize(configuration = {})
      @configuration = configuration
    end

    def required?
      @configuration[:required] == true
    end

    def hint
      @configuration[:hint]
    end

    def parse(input)
      return nil if missing_value?(input)
      _parse(input)
    end

    def self.define(configuration = {})
      new(configuration)
    end

    private

    def missing_value?(input)
      input.nil? || input == ''
    end

  end

  class String < AttributeType
    self.type = :string
    def _parse(value)
      value.to_s
    end
  end

  class Number < AttributeType
    def min
      @configuration[:min]
    end
    def max
      @configuration[:min]
    end
  end

  class Integer < Number
    self.type = :integer
    def _parse(value)
      value.to_i
    end
  end

  class Float < Number
    self.type = :float
    def _parse(value)
      value.to_f
    end
  end

  class TimeOfYear < AttributeType
    self.type = :time_of_year
    def _parse(input)
      return nil if missing_value?(input[:month]) || missing_value?(input[:day_of_month])
      ::TimeOfYear.new(input[:month].to_i, input[:day_of_month].to_i)
    end
  end

  class TimeOfDay < AttributeType
    self.type = :time_of_day
    def _parse(input)
      return nil if missing_value?(input[:hour]) || missing_value?(input[:minutes])
      ::TimeOfDay.new(input[:hour].to_i, input[:minutes].to_i)
    end
  end

  class TimeOfDay30mins < AttributeType
    self.type = :time_of_day_30
    def _parse(input)
      return nil if missing_value?(input[:hour]) || missing_value?(input[:minutes])
      ::TimeOfDay30mins.new(input[:hour].to_i, input[:minutes].to_i)
    end
  end

  class Boolean < AttributeType
    self.type = :boolean
    def _parse(input)
      ['true', '1'].include?(input.to_s) ? true : nil
    end
  end


  class Date < AttributeType
    self.type = :date
    def _parse(input)
      ::Date.parse(input)
    end
  end

  class DateTime < AttributeType
    self.type = :date_time
    def _parse(input)
      ::DateTime.parse(input)
    end
  end

  class Hash < AttributeType
    self.type = :hash

    def structure
      @configuration.fetch(:structure){ {} }
    end

    def _parse(input)
      easy_access = JSON.parse(JSON[input], symbolize_names: true) # can't get indifferent access hash to work here
      structure_with_values = structure.inject({}) do |parsed, (key, type)|
        parsed_value = type.parse(easy_access[key])
        parsed[key] = parsed_value unless parsed_value.nil?
        parsed
      end
      (!required? && structure_with_values.empty?) ? nil : structure_with_values
    end
  end

  class Symbol < AttributeType
    self.type = :symbol

    def allowed_values
      @configuration[:allowed_values]
    end

    def _parse(value)
      symbolised = value.to_s.to_sym
      unless allowed_values.nil? || allowed_values.include?(symbolised)
        raise InvalidAttributeValue, "Invalid value '#{value}' for Symbol with allowed values '#{allowed_values.join(', ')}'"
      end
      symbolised
    end
  end

end
