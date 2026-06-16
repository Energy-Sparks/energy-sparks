# frozen_string_literal: true

module MeterAttributes
  class OverrideBadReadings < MeterAttributeTypes::AttributeBase
    id :meter_corrections_override_bad_readings
    key :override_bad_readings
    aggregate_over :meter_corrections
    name 'Meter correction > Substitute bad readings'
    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date: MeterAttributeTypes::Date.define(required: true),
        end_date: MeterAttributeTypes::Date.define(required: true)
      }
    )
  end
end
