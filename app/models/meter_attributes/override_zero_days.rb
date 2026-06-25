# frozen_string_literal: true

module MeterAttributes
  class OverrideZeroDays < MeterAttributeTypes::AttributeBase
    id  :override_zero_days_electricity_readings
    key :override_zero_days_electricity_readings
    aggregate_over :meter_corrections
    name 'Meter correction > Override All Zero Days'
    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date: MeterAttributeTypes::Date.define,
        end_date: MeterAttributeTypes::Date.define,
        override: MeterAttributeTypes::Symbol.define(allowed_values: %i[on intelligent_solar off])
      }
    )
  end
end
