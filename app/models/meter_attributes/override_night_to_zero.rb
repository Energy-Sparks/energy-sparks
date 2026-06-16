# frozen_string_literal: true

module MeterAttributes
  class OverrideNightToZero < MeterAttributeTypes::AttributeBase
    id :meter_corrections_override_night_to_zero
    key :override_night_to_zero
    aggregate_over :meter_corrections
    name 'Meter correction > Set night time readings to zero'

    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date: MeterAttributeTypes::Date.define,
        end_date: MeterAttributeTypes::Date.define
      }
    )
  end
end
